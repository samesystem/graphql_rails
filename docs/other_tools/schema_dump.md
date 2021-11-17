# Schema Dump

GraphqlRails includes rake task to allow creating schema snapshots easier:

```bash
rake graphql_rails:schema:dump
```

## Dumping non default schema

You can have multiple graphql schemas. Read more about this in [routes section](components/routes).

### Dumping single schema

In order to generate schema for one of groups, provide optional `name` argument:

```bash
rake graphql_rails:schema:dump['your_group_name']
```

or using ENV variable `SCHEMA_GROUP_NAME`:

```bash
SCHEMA_GROUP_NAME="your_group_name" rake graphql_rails:schema:dump
```

### Dumping multiple schemas

In order to generate multiple schemas at once, separate group names by comma:

```bash
rake graphql_rails:schema:dump['your_group_name, your_group_name2']
```

or using ENV variable `SCHEMA_GROUP_NAME`:

```bash
SCHEMA_GROUP_NAME="your_group_name, your_group_name2" rake graphql_rails:schema:dump
```

## Dumping schema in to non default path

By default schema will be dumped to `spec/fixtures/graphql_schema.graphql` path. If you want different schema path, add `GRAPHQL_SCHEMA_DUMP_PATH` env variable, like this:

```bash
GRAPHQL_SCHEMA_DUMP_PATH='path/to/my/schema.graphql' rake graphql_rails:schema:dump
```
