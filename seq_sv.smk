## change each of the variables below to match your data
## if using genome assemblies instead of fastq files, see the note under the maptoref rule params
ref = "MAP_genomes/GCF_025665475.K10_genomic.fna"
seqdir = "fastq_files/"
ext = ".fastq.gz"


STRAINS = glob_wildcards(seqdir + "{s}/{strain}" + ext).strain

rule all:
    input:
        "all_strains_sv.vcf"


rule maptoref:
    input:
        fq=seqdir + "{strain}/{strain}" + ext,
        rf=ref
    output:
        sam=seqdir + "{strain}/{strain}_aln.sam"
    params:
        x="map-ont", ## use "asm20" for genome to genome mapping (not recommended for finding SVs)
    shell:
        "minimap2 -t {threads} -a -x {params.x} {input.rf} {input.fq} > {output.sam}" 


rule samtobam:
    input:
        sam=rules.maptoref.output.sam
    output:
        bam=seqdir + "{strain}/sorted.{strain}_aln.bam",
        idx=seqdir + "{strain}/sorted.{strain}_aln.bam.bai"
    shell:
        """
        samtools sort -o {output.bam} {input.sam} --threads {threads}
        samtools index {output.bam} --threads {threads}
        """

rule findsvs:
    input:
        bam=rules.samtobam.output.bam,
        rf=ref
    output:
        vcf=seqdir + "{strain}/{strain}_sv.vcf",
        snf=seqdir + "{strain}/{strain}_sv.snf"
    shell:
        "sniffles -i {input.bam} -v {output.vcf} --snf {output.snf} --reference {input.rf} --output-rnames -t {threads}"


rule allsamplesvs:
    input:
        snf=expand(seqdir + "{strain}/{strain}_sv.snf", strain=STRAINS)
    output:
        vcf="all_strains_sv.vcf"
    shell:
        "sniffles -i {input.snf} -v {output.vcf}"


## get a quick count of each SV type for each strain: 
# for file in fastq_files/*/*_sv.vcf; do s=$( echo "$file" | cut -f 2 -d '/' ); echo ''; echo "$s"; grep -v '^#' "$file" | cut -f 3 | cut -f 2 -d '.' | sort | uniq -c; done 

## info on VCF file type: https://samtools.github.io/hts-specs/VCFv4.2.pdf

## https://github.com/lh3/minimap2
## https://www.htslib.org/doc/samtools.html
## https://github.com/smolkmo/Sniffles2.2