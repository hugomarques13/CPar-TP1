#!/bin/bash

# Script de teste para benchmark de threads
# Testa de 1 a 20 threads

# Nome do executável
EXECUTABLE="../zpic"
INPUT_DIR="../input"
MAKE_COMMAND="make run"

# Ficheiro de output
OUTPUT_FILE="thread_benchmark_results.txt"
CSV_FILE="thread_benchmark.csv"

# Array para armazenar resultados
declare -a results
declare -a times

# Verificar se o directório input existe
if [ ! -d "$INPUT_DIR" ]; then
    echo "Erro: Directório $INPUT_DIR não encontrado!"
    exit 1
fi

# Compilar o código primeiro
echo "A compilar o código..."
make clean
make

if [ ! -f "$EXECUTABLE" ]; then
    echo "Erro: Executável $EXECUTABLE não foi criado!"
    exit 1
fi

echo "Iniciando benchmark de threads..."
echo "======================================"

# Executar para diferentes números de threads
for threads in {1..20}; do
    echo "A testar com $threads thread(s)..."
    
    # Definir número de threads
    export OMP_NUM_THREADS=$threads
    
    # Executar e medir o tempo
    start_time=$(date +%s.%N)
    $MAKE_COMMAND > /dev/null 2>&1
    end_time=$(date +%s.%N)
    
    # Calcular tempo decorrido
    elapsed_time=$(echo "$end_time - $start_time" | bc)
    
    # Guardar resultados
    results[$threads]="$threads $elapsed_time"
    times[$threads]=$elapsed_time
    
    echo "  Threads: $threads, Tempo: ${elapsed_time}s"
done

# Calcular speedup (relativo a 1 thread)
base_time=${times[1]}
echo ""
echo "Resultados do Benchmark:"
echo "======================================"

# Escrever para ficheiro de texto
echo "Resultados do Benchmark de Threads" > $OUTPUT_FILE
echo "======================================" >> $OUTPUT_FILE
echo "Threads | Tempo (s) | Speedup | Eficiência (%)" >> $OUTPUT_FILE
echo "--------|-----------|---------|---------------" >> $OUTPUT_FILE

# Escrever para CSV
echo "Threads,Tempo(s),Speedup,Eficiencia(%)" > $CSV_FILE

for threads in {1..20}; do
    time=${times[$threads]}
    if [ $(echo "$base_time > 0" | bc) -eq 1 ]; then
        speedup=$(echo "scale=2; $base_time / $time" | bc)
        efficiency=$(echo "scale=2; ($speedup / $threads) * 100" | bc)
    else
        speedup="N/A"
        efficiency="N/A"
    fi
    
    # Formatar output para tabela
    printf "%7d | %9.3f | %7.2f | %13.2f\n" $threads $time $speedup $efficiency >> $OUTPUT_FILE
    echo "$threads,$time,$speedup,$efficiency" >> $CSV_FILE
    
    # Mostrar no terminal também
    printf "%7d | %9.3f | %7.2f | %13.2f\n" $threads $time $speedup $efficiency
done

echo ""
echo "Resultados guardados em:"
echo "  - $OUTPUT_FILE (formato de tabela)"
echo "  - $CSV_FILE (formato CSV)"

# Gerar gráfico simples (se gnuplot estiver disponível)
if command -v gnuplot &> /dev/null; then
    echo "A gerar gráfico..."
    
    gnuplot << EOF
    set terminal pngcairo size 800,600 enhanced font 'Verdana,10'
    set output 'thread_benchmark_plot.png'
    set title 'Benchmark de Threads - Tempo de Execução e Speedup'
    set xlabel 'Número de Threads'
    set ylabel 'Tempo (s)'
    set y2label 'Speedup'
    set y2tics
    set grid
    
    plot '$CSV_FILE' using 1:2 with linespoints title 'Tempo (s)' axes x1y1, \
         '$CSV_FILE' using 1:3 with linespoints title 'Speedup' axes x1y2
EOF
    echo "  - thread_benchmark_plot.png (gráfico)"
fi

echo ""
echo "Benchmark completo!"