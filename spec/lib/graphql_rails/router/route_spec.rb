# frozen_string_literal: true

module GraphqlRails
  RSpec.describe Router::Route do
    subject(:route) { described_class.new(:dummy, **params) }

    let(:params) do
      {
        on: :member,
        to: 'dummies#show'
      }
    end

    let(:controller) do
      user_type = Class.new(GraphQL::Schema::Object) do
        graphql_name 'User'

        field :name, String, null: false
      end

      Class.new(GraphqlRails::Controller) do
        action(:show).permit(:name!).returns(user_type).paginated(max_page_size: 100)

        def show
          'OK'
        end
      end
    end

    let(:type) do
      Class.new do
        include GraphqlRails::Model

        graphql.name("SomeDummyModelType#{rand(10**9)}")
        graphql.attribute(:id)
      end
    end

    describe '#path' do
      subject(:path) { route.path }

      it 'returns correct path' do
        expect(path).to eq('dummies#show')
      end

      context 'when module is given' do
        let(:params) { super().merge(module: 'foo/bar') }

        it 'includes module in path' do
          expect(path).to eq('foo/bar/dummies#show')
        end
      end
    end

    describe '#collection?' do
      subject(:collection?) { route.collection? }

      context 'when "on" is :member' do
        it { is_expected.to be false }
      end

      context 'when "on" is :collection' do
        let(:params) { super().merge(on: :collection) }

        it { is_expected.to be true }
      end
    end

    describe '#show_in_group?' do
      subject(:show_in_group?) { route.show_in_group?(group_name) }

      let(:group_name) { :foo }

      context 'when groups are not given' do
        it { is_expected.to be true }
      end

      context 'when group is given' do
        let(:params) { super().merge(groups: %i[foo]) }

        context 'when group is correct' do
          it { is_expected.to be true }
        end

        context 'when group is incorrect' do
          let(:group_name) { :bar }

          it { is_expected.to be false }
        end
      end
    end

    describe '#field_options' do
      subject(:field_options) { route.field_options }

      before do
        allow(Object).to receive(:const_get).with('DummiesController').and_return(controller)
        allow(Object).to receive(:const_get).with('User').and_return(type)
      end

      it 'returns correct options' do
        expect(field_options).to include(
          extras: [:lookahead],
          max_page_size: 100
        )
      end
    end
  end
end
