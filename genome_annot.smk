## change each of the variables below to match your data
refdir = "MAP_genomes/"
refname = "GCF_025665475.K10"
seqdir = "MAH_genomes/"
idfa = "_genomic.fna"

STRAINS = glob_wildcards(seqdir + "{s}/{strain}" + idfa).strain
FILETYPES = ['embl', 'faa', 'ffn', 'fna', 'gbff', 'gff3', 'hypotheticals.faa', 'hypotheticals.tsv', 'inference.tsv', 'json', 'log', 'png', 'svg', 'tsv', 'txt']

rule all:
    input:
        "db/amrfinderplus-db/latest",
        expand(seqdir + "{strain}/{strain}_bakta.{ext}", strain=STRAINS, ext=FILETYPES),
        expand(refdir + refname + "_bakta.{ext}", ext=FILETYPES)


rule baktadb:
    output:
        db="db/bakta.db"
    shell:
        "bakta_db download --type full"


rule baktaMAP:
    input:
        fna=refdir + refname + idfa,
    output:
        js=expand(refdir + refname + "_bakta.{ext}", ext=FILETYPES)
    params:
        dir=refdir,
        db="db/",
        pref=refname + "_bakta",
    shell:
        "bakta --force --db {params.db} -o {params.dir} -p {params.pref} -t {threads} --genus Mycobacterium --species avium --gram + {input.fna} --complete"


rule baktaMAH:
    input:
        fna=seqdir + "{strain}/{strain}" + idfa,
    output:
        js=expand(seqdir + "{{strain}}/{{strain}}_bakta.{ext}", ext=FILETYPES)
    params:
        dir=seqdir + "{strain}",
        db="db/",
        pref="{strain}_bakta",
    shell:
        "bakta --force --db {params.db} -o {params.dir} -p {params.pref} -t {threads} --genus Mycobacterium --species avium --gram + {input.fna} --complete"
