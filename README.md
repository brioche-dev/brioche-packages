# Brioche Packages

This repo contains the sources for all published packages for [Brioche](https://brioche.dev). Every directory under `packages/` will get built and published to the registry automatically when the repo is updated.

## Repo structure

- The repo itself is a [Brioche workspace](https://brioche.dev/docs/core-concepts/workspaces), meaning packages within this repo will directly reference other packages within this repo.
    - For development, this means you can make changes to multiple packages at once and publish the changes together.
- Each directory under `packages/` gets built and published to the registry.

## Contributing new packages

To contribute a new package, check out this repo, create a new project under `packages/`, then submit it as a PR!

For example, if you were going to add a new package called "fizzbuzz", you would create the directory `packages/fizzbuzz/`, add the file `project.bri`, then write the build script. You could also test it locally by running `brioche build -p ./packages/fizzbuzz`.

Every published package must include a `project` export setting its name (and optionally a version number):

```ts
export const project = {
  name: "somepackage",
  version: "1.0.2",
};
```

> **Note**: For the time being, all packages must have a default export that returns a recipe! For packages that shouldn't have a default export, you can add a dummy default export as a temporary measure
