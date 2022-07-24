CHR = []
for i in range(1,23):
    CHR.append(str(i))
print(CHR)

#CODE = [str(4815)]
CODE = []
for i in range(2406,2430):
    CODE.append(str(2*i+1))
print(CODE)

# dry-run vs. actual run???


rule all: ## output you want / how to list several things?
    input:
        expand("data/1kg_prs/b-{code}/ieu-b-{code}_1kg_dosage.bed", chr=CHR, code=CODE)


rule compute_freqs:
    input: ### what if input != output from prev func
        vcf="/project2/jnovembre/data/external_public/1kg_phase3/haps/ALL.chr{chr}.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf.gz",
        id="/project2/jjberg/hkim/igsr_samples_EUR_id_dup.txt"
    output:
        "data/1kg_frq/1kg_old_build37/1kg_chr{chr}_high_frq.txt"
    shell:
        """
    	plink --vcf {input.vcf} --freq --snps-only --rm-dup --keep {input.id} --out data/1kg_frq/1kg_old_build37/chr{wildcards.chr}
            awk '$5 >= 0.05 && $5 != "NA"' data/1kg_frq/1kg_old_build37/chr{wildcards.chr}.frq > {output}
    	rm data/1kg_frq/1kg_old_build37/chr{wildcards.chr}.*
    	"""

rule filter_gwas:
    input:
        vcf="data/sib_gwas/ieu-b-{code}.vcf",
        perl="/project2/jjberg/hkim/filter_sibgwas_high_freq_vars.pl" ## ???? see if this works
    output:
        "data/sib_gwas/filtered/ieu-b-{code}_highfrq.txt"
    shell:
        """
    	perl {input.perl} {input.vcf} > {output}
    	"""

rule LD_clumping:
    input:
        vcf="data/sib_gwas/filtered/ieu-b-{code}_highfrq.txt",
        perl="/project2/jjberg/hkim/filter_sibgwas_LDclumping_v2.pl"
    output:
        file="data/sib_gwas/filtered/ieu-b-{code}_highfrq_LDclumped.txt",
        trns="data/sib_gwas/filtered/ieu-b-{code}_highfrq_LDclumped_transformed.txt",
        fltr="data/sib_gwas/filtered/ieu-b-{code}_highfrq_LDclumped_transformed_pvalfiltered.txt",
        id="data/sib_gwas/filtered/ieu-b-{code}_highfrq_LDclumped_transformed_rsID.txt"
    shell:
        """
    	perl {input.perl} {input.vcf} > {output.file}
        awk -F'[ :\t]' '{{print $1,$2,$3,$4,$5,$11,$12,$13,$14}}' {output.file} > {output.trns}
        sed -i '1s/#CHROM POS ID REF ALT/CHROM POS ID REF ALT ES SE LP SS/g' {output.trns}
        awk '$8 < 0.05 || $5 == "ALT"' {output.trns} > {output.fltr}
        awk '{{print $3}}' {output.fltr} > {output.id}
        """

rule filter_1kg_seqdata: ##???
    input:
        bfile="/project2/jjberg/data/1kg/plink-files/files/EUR/all_chroms.bed",
        id="data/sib_gwas/filtered/ieu-b-{code}_highfrq_LDclumped_transformed_rsID.txt"
    output:
        "data/1kg_prs/b-{code}/ieu-b-{code}_1kg_dosage.bed"
    shell:
        """
    	plink --bfile /project2/jjberg/data/1kg/plink-files/files/EUR/all_chroms --extract {input.id} --make-bed --out data/1kg_prs/b-{wildcards.code}/ieu-b-{wildcards.code}_1kg_dosage
        """