# Testing

## Testing graphql controllers in RSpec

### Setup

Add those lines in your `spec/spec_helper.rb` file

```ruby
# spec/spec_helper.rb
require 'graphql_rails/rspec_controller_helpers'

RSpec.configure do |config|
  config.include(GraphqlRails::RSpecControllerHelpers, type: :graphql_controller)
  # ... your other configuration ...
end
```

### Helper methods

There are 3 helper methods:

* `mutation(:your_controller_action_name, params: {}, context: {})`. `params` and `context` are optional
* `query(:your_controller_action_name, params: {}, context: {})`. `params` and `context` are optional
* `response`. Response is set only after you call `mutation` or `query`

### Test examples

```ruby
class MyGraphqlController
  action(:create_user).permit(:full_name, :email).returns(User)
  action(:index).returns('String')

  def index
    "Called from index: #{params[:message]}"
  end

  def create_user
    User.create!(params)
  end
end

RSpec.describe MyGraphqlController, type: :graphql_controller do
  describe '#index' do
    it 'is successful' do
      query(:index)
      expect(response).to be_successful
    end

    it 'returns correct message' do
      query(:index, params: { message: 'Hello world!' })
      expect(response.result).to eq "Called from index: Hello world!"
    end
  end

  describe '#create_user' do
    context 'when bad email is given' do
      it 'fails' do
        mutation(:create_user, params { email: 'bad' })
        expect(response).to be_failure
      end

      it 'contains errors' do
        mutation(:create_user, params { email: 'bad' })
        expect(response.errors).not_to be_empty
      end
    end
  end
end
```
