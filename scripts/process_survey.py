#!/usr/bin/env python3
# Procesa el CSV de encuesta y genera tablas resumen en LaTeX y gráficos PNG
import pandas as pd
import matplotlib.pyplot as plt
from pathlib import Path

root = Path(__file__).resolve().parents[1]
# Prefer cleaned CSV if exists (created by the PowerShell cleaner)
clean_csv = root / 'anexos' / 'data' / 'encuesta_clean.csv'
raw_csv = root / 'anexos' / 'data' / 'encuesta.csv'
data_in = clean_csv if clean_csv.exists() else raw_csv
out_fig = root / 'anexos' / 'figures'
out_tex = root / 'anexos' / 'encuesta_tablas.tex'

if not data_in.exists():
    print('CSV no encontrado:', data_in)
    raise SystemExit(1)

# Leer CSV con pandas, intentar detectar separador y encoding
try:
    df = pd.read_csv(data_in, encoding='utf-8')
except Exception:
    df = pd.read_csv(data_in, encoding='latin-1')

# Limpiar nombres de columnas (quitando espacios extra)
df.columns = [c.strip() for c in df.columns]

# Columnas de interés (según el CSV proporcionado)
age_col = '¿A que rango de edad perteneces?'
control_col = '¿Llevas actualmente un control de tus gastos?  '
pay_col = ' ¿Qué rango de precio considerarías justo por mes?  '
ticket_col = '¿Que tipo de tickets recibes más seguido?'

# Generar frecuencias (manejar si columna no existe)
summary = {}
for col, name in [(age_col,'age'), (control_col,'control'), (pay_col,'payrange'), (ticket_col,'ticket')] :
    if col in df.columns:
        counts = df[col].fillna('No especificado').astype(str).value_counts()
        summary[name] = counts
    else:
        summary[name] = None

# Escribir archivo LaTeX con tablas de frecuencias
with open(out_tex, 'w', encoding='utf-8') as f:
    f.write('% Tabla resumen generada automáticamente por scripts/process_survey.py\n')
    if summary['age'] is not None:
        f.write('\\section{Resumen: Rango de edad}\\n')
        f.write('\\begin{center}\\begin{tabular}{lr}\\toprule\\n')
        f.write('Rango de edad & Frecuencia \\\\ \\midrule\\n')
        for idx, val in summary['age'].items():
            f.write(f'{idx} & {val} \\\\n')
        f.write('\\bottomrule\\end{tabular}\\end{center}\\n')
    if summary['control'] is not None:
        f.write('\\section{Resumen: ¿Llevas control de tus gastos?}\\n')
        f.write('\\begin{center}\\begin{tabular}{lr}\\toprule\\n')
        f.write('Respuesta & Frecuencia \\\\ \\midrule\\n')
        for idx, val in summary['control'].items():
            f.write(f'{idx} & {val} \\\\n')
        f.write('\\bottomrule\\end{tabular}\\end{center}\\n')
    if summary['payrange'] is not None:
        f.write('\\section{Resumen: Rango de precio aceptable}\\n')
        f.write('\\begin{center}\\begin{tabular}{lr}\\toprule\\n')
        f.write('Rango & Frecuencia \\\\ \\midrule\\n')
        for idx, val in summary['payrange'].items():
            f.write(f'{idx} & {val} \\\\n')
        f.write('\\bottomrule\\end{tabular}\\end{center}\\n')
    if summary['ticket'] is not None:
        f.write('\\section{Resumen: Tipo de tickets más frecuentes}\\n')
        f.write('\\begin{center}\\begin{tabular}{lr}\\toprule\\n')
        f.write('Tipo de ticket & Frecuencia \\\\ \\midrule\\n')
        for idx, val in summary['ticket'].items():
            f.write(f'{idx} & {val} \\\\n')
        f.write('\\bottomrule\\end{tabular}\\end{center}\\n')

# Generar gráficas: distribución por edad y por rango de precio (si existen)
out_fig.mkdir(parents=True, exist_ok=True)
if summary['age'] is not None:
    plt.figure(figsize=(6,4))
    summary['age'].sort_index().plot(kind='bar')
    plt.title('Distribución por rango de edad')
    plt.xlabel('Rango de edad')
    plt.ylabel('Frecuencia')
    plt.tight_layout()
    plt.savefig(out_fig / 'age_distribution.png', dpi=150)
    plt.close()

if summary['payrange'] is not None:
    plt.figure(figsize=(6,4))
    summary['payrange'].sort_index().plot(kind='bar')
    plt.title('Rango de precio considerado justo')
    plt.xlabel('Rango de precio (MXN)')
    plt.ylabel('Frecuencia')
    plt.tight_layout()
    plt.savefig(out_fig / 'payrange_distribution.png', dpi=150)
    plt.close()

print('Generados:', out_tex, 'y figuras en', out_fig)
