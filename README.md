# Example Infrastructure Repo

This repository can be used as a template for how to deploy a central infrastructure repository with a GitOps Workflow.

## Prerequisites

* Kustomize is installed and on the path
* Currently the scripts are only running on linux and macos

## Getting Started

The structure of this repo is quite simple:

```sh
.
├── README.md
├── apps
│   └── k8s
│       ├── global
│       ├── kustomization.yaml
│       └── namespaces
└── scripts
```

* **/apps** contains all deployment manifests and is the folder referenced by GitOps process.
* **/scripts** contains util scripts to support the workflow.

In case you want to add a new namespace, just provide a new folder under namespaces with the namespace name and 
add application folders to it.

Example:

```sh
routing-system
├── routing-system-ns.yaml
└── traefik
    ├── base
    │   ├── kustomization.yaml
    │   └── traefik-helm.yaml
    └── overlays
        ├── cloud
        │   ├── kustomization.yaml
        │   └── values
        │       └── values.yaml
        └── local
            ├── kustomization.yaml
            └── values
                └── values.yaml
````

As you can see above, the routing namespace consists of a namespace yaml file and the various applications. In this 
case we have the traefik ingress controller as an example.
The structure below traefik can be desinged however you like it, but in our case, a classic kustomization structure is used.
We leverage the GitOps Toolkit (Flux v2), so we have Helmreleases and Helmrepostories in the base folder and custom
values as Configmap in the overlays.

> The structure below the namespaces can be completely setup by your needs.

After you have modified your files, do not forget to generate the kustomization.yaml with the utility script.

```sh
# Make sure you are at the root of the project
./scripts/generate-cloud-kustomize.sh
```

This script makes sure, that the kustomization.yaml is generated with the appropriate overlays for cloud. Always
ensure to run this after changed and commit it to git, so that the referencing fleet repository is deploying everything you added.

> This script is a workaround, maybe one day we find a better solution to target only the overlays that are relevant for cloud.
> Sadly kustomize create has no command to ignore certain overlays.

## Additional Tips

### Git Tag Strategy

By tagging this repository in semantic versioning style, we are able to reference various versions of this
repository from the central fleet repository. By this, we ensure that changing this repo won't affect all clusters immediately.

You could point your infrastructure test cluster to master and the other clusters to a specifc tag. After an 
update is approved, you can rollout the change to your cluster one by one.

We use this strategy only for infrastructure repositories, due to the fact, that this repository is providing
critical infrastructure services and the blast radius could be immense.

### Helm Workflow

In this repo you can see a specifc setup for Helm Charts leveraging Kustomize.
The idea is to place the values.yaml file for your Helm Chart in the repository and 
then to let Kustomize generate a Configmap out of it. This Configmap is then referenced by
the Helm Resources of Flux v2. In case we want to update the values, we just fetch the most
recent values from remote and compare them. After this we can test the update with the local 
setup. In case everything is ok, the values for cloud are adjusted and committed. 