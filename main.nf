#!/usr/bin/env nextflow

// Each task prints the directives it ended up with. Every config layer in this
// demo writes a different value, so the output names the layer that won.

def report(task) {
    def ext = task.ext.collect { k, v -> "${k}:${v}" }.sort().join(',')
    return "process=${task.process} attempt=${task.attempt} label=${task.label} queue=${task.queue} " +
           "cpus=${task.cpus} memory=${task.memory} time=${task.time} maxRetries=${task.maxRetries} ext=[${ext}]"
}

// Plain nf-core-style module: resources come only from a label.
process FASTQC {
    label 'process_medium'
    output: stdout
    script:
    """
    echo "${report(task)}"
    """
}

// The FD-7987 case: code label process_high, relabelled from config.
process CELLRANGER_MULTI {
    label 'process_high'
    output: stdout
    script:
    """
    echo "${report(task)}"
    """
}

// Code directives, plus a retry: fails until attempt 3.
process SAMTOOLS_SORT {
    label 'process_low'
    cpus 1
    time '1h'
    errorStrategy 'retry'
    maxRetries 1
    ext set_by: 'code', code: 'y'
    output: stdout
    script:
    """
    echo "${report(task)}"
    echo "${report(task)}" >&2
    [ ${task.attempt} -ge 3 ] || exit 1
    """
}

// Called from the top-level workflow, so its simple and fully-qualified names are the same.
process MULTIQC {
    label 'process_single'
    input: val lines
    output: stdout
    script:
    """
    echo "${report(task)} params.marker=${params.marker}"
    """
}

workflow NFCORE_DEMO {
    main:
    out = FASTQC().mix(CELLRANGER_MULTI(), SAMTOOLS_SORT())
    emit:
    out
}

workflow {
    lines = NFCORE_DEMO()
    all = lines.mix(MULTIQC(lines.collect()))
    all.view { it.trim() }
    all.collectFile(name: 'resolution.txt', storeDir: params.outdir, sort: true)
}
