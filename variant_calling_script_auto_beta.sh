mkdir ~dc_workshop/results

touch run_variant_calling.sh

nano run_variant_calling.sh

set -e
cd ~/dc_workshop/results

genome=~/dc_workshop/data/ref_genome/ecoli_rel606.fasta

bwa index $genome

mkdir -p sam bam bcf vcf

for fq1 in ~/dc_workshop/data/trimmed_fastq_small/*_1.trim.sub.fastq
    do
    echo "working with file $fq1"

    base=$(basename $fq1 _1.trim.sub.fastq)
    echo "base name is $base"

    fq1=~/dc_workshop/data/trimmed_fastq_small/${base}_1.trim.sub.fastq
    fq2=~/dc_workshop/data/trimmed_fastq_small/${base}_2.trim.sub.fastq
    sam=~/dc_workshop/results/sam/${base}.aligned.sam
    bam=~/dc_workshop/results/bam/${base}.aligned.bam
    sorted_bam=~/dc_workshop/results/bam/${base}.aligned.sorted.bam
    raw_bcf=~/dc_workshop/results/bcf/${base}_raw.bcf
    variants=~/dc_workshop/results/vcf/${base}_variants.vcf
    final_variants=~/dc_workshop/results/vcf/${base}_final_variants.vcf

    bwa mem $genome $fq1 $fq2 > $sam
    samtools view -S -b $sam > $bam
    samtools sort -o $sorted_bam $bam
    samtools index $sorted_bam
    bcftools mpileup -O b -o $raw_bcf -f $genome $sorted_bam
    bcftools call --ploidy 1 -m -v -o $variants $raw_bcf
    vcfutils.pl varFilter $variants > $final_variants

    done

#Explicación del script

	#detiene la ejecución si encuentra algún error 
set -e 

#ingresamos a la carpeta results/
cd ~/dc_workshop/results  

#crea una variable con genome
genome=~/dc_workshop/data/ref_genome/ecoli_rel606.fasta 
#indexa el genoma de referencia con bwa
bwa index $genome 

#creación de 04 carpetas en results/
mkdir -p sam bam bcf vcf 

#itera sobre todos los archivos de secuencias 
for fq1 in ~/dc_workshop/data/trimmed_fastq_small/*_1.trim.sub.fastq
    do
    echo "working with file $fq1"

#extrae el nombre base del archivo eliminado _1.trim.sub.fastq
    base=$(basename $fq1 _1.trim.sub.fastq)
    echo "base name is $base"

#define el nombre de los archivos de lectura usando el nombre base fq1
    fq1=~/dc_workshop/data/trimmed_fastq_small/${base}_1.trim.sub.fastq

#define el nombre de los archivos de lectura usando el nombre base fq2
    fq2=~/dc_workshop/data/trimmed_fastq_small/${base}_2.trim.sub.fastq

#define el nombre de los archivos SAM de salida para la alineación 
    sam=~/dc_workshop/results/sam/${base}.aligned.sam

#define el nombre de los archivos BAM de salida para la alineación
    bam=~/dc_workshop/results/bam/${base}.aligned.bam

#define el nombre de los archivos BAM de salida ordenad
sorted_bam=~/dc_workshop/results/bam/${base}.aligned.sorted.bam
    raw_bcf=~/dc_workshop/results/bcf/${base}_raw.bcf

#define el nombre de los archivos VCF DE VARIANTES DE LLAMADA  
variants=~/dc_workshop/results/vcf/${base}_variants.vcf

#define el nombre de los archivos VCF DE VARIANTES DE LLAMADA filtradas
final_variants=~/dc_workshop/results/vcf/${base}_final_variants.vcf

#Utiliza Bwa para alinear las lecturas de  $fq1 $fq2 
bwa mem $genome $fq1 $fq2 > $sam

#convierte el archivo SAM a formato BAM utiliza Samtools
samtools view -S -b $sam > $bam

#utiliza Samtools ordenar 
samtools sort -o $sorted_bam $bam
   
#utiliza Samtools para indexar 
samtools index $sorted_bam

# utiliza bcftools para generar el archivo BCF 
    bcftools mpileup -O b -o $raw_bcf -f $genome $sorted_bam

# utiliza bcftools con una haploidia para generar el archivo BCF y guarda el resultado en variants
    bcftools call --ploidy 1 -m -v -o $variants $raw_bcf

# utiliza para filtrar y procesar variants, guarda el resultado en final variants
    vcfutils.pl varFilter $variants > $final_variants

    done

