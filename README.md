# nf-config-resolution-demo

A small pipeline for showing how Nextflow resolves process directives when config comes from several places: the process body, the repo's `nextflow.config` (with nf-core style `conf/base.config` and `conf/modules.config`), a profile, and the config fields of Seqera Platform's compute environment and launchpad.

Each task prints `task.process`, `task.label`, `task.queue`, `task.cpus`, `task.memory`, `task.time`, `task.maxRetries` and `task.ext`. Each config layer writes different marker values, so the output shows which layer won.

`examples/` holds the compute environment and launchpad configs used in the write-up, and a local stand-in for what Platform injects.

Made for Seqera support ticket FD-7987. No real workload: every task only runs `echo`.
