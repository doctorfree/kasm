## Restart Policy

By default, Workspaces applies a restart policy to containers of
`unless-stopped`, which means the container is automatically restarted
unless it is manually stopped.

This may or may not be desired. To launch containers that perform a task
and exit, the default restart policy must be overridden.

Workspaces will also run every container as USER 1000 unless overridden.

In the Workspaces Admin UI, navigate to Workspaces, edit the desired Workspace
and in the `Docker Run Config Override` (JSON) field, set the restart policy to
`on-failure` and optionally the container user as shown here:

```json
{"restart_policy":{"Name":"on-failure","MaximumRetryCount":5}, "user": "root"}
```

