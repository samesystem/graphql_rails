# Schema Dump

GraphqlRails includes rake task to allow creating schema snapshots easier:

```bash
rake graphql_rails:schema:dump
```

## Dumping only selected schema groups

You can specify which schema groups you want to dump. In order to do so, provide groups list as rake task argument and separate group names by comma:

```bash
rake graphql_rails:schema:dump['your_group_name, your_group_name2']
```

You can do this also by using ENV variable `SCHEMA_GROUP_NAME`:

```bash
SCHEMA_GROUP_NAME="your_group_name, your_group_name2" rake graphql_rails:schema:dump
```

## Dumping schema in to non default folder

By default schema will be dumped to `spec/fixtures` directory. If you want different schema path, add `GRAPHQL_SCHEMA_DUMP_DIR` env variable, like this:

```bash
GRAPHQL_SCHEMA_DUMP_DIR='path/to/graphql/dumps' rake graphql_rails:schema:dump
```
