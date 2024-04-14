#!/bin/bash



for ((i=15; i<=80; i+=5));
do
	mkdir k${i};
	./platanus assemble -m 6 -k $i -o ${i} -f lib1_*.fq -o k${i}/k${i};
	./platanus scaffold -OP lib2_1.fq lib2_2.fq -c k${i}/k${i}_contig.fa -o k${i}/scaff_k${i};

	python quast-5.2.0/quast.py k${i}/scaff_k${i}_scaffold.fa -o k${i}/ -m 0;


done

# Asigna el nombre de la tabla a una variable
tabla="tabla_conjunta"

# Crea el archivo de tabla si no existe y elimina su contenido si ya existe
> "$tabla"

# Itera sobre los archivos 20, 40 y 80
for ((i=15; i<=80; i+=5));
do
    if [ ! -s "$tabla" ]; then
        # Si es el primer archivo y la tabla está vacía, copia todo el contenido del archivo en $tabla
        cat "k${i}/report.tsv" > "$tabla"
    else
        # Si no es el primer archivo, agrega la columna 2 del archivo como una nueva columna en $tabla
        awk -F'\t' '{print $2}' "k${i}/report.tsv" | paste -d '\t' "$tabla" - > "$tabla.tmp" && mv "$tabla.tmp" "$tabla"
    fi
done

# Guarda la tabla resultante
cp "$tabla" "tabla_final.tsv"

# Muestra el contenido de la tabla
cat "$tabla" | column -t -s $'\t'
