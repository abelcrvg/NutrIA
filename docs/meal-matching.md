# Matching de refeições

O NutrIA normaliza a entrada antes de procurar uma combinação específica.

## Ordem
1. normalizar acentos, caixa, pontuação e espaços;
2. substituir aliases conhecidos (ex.: `refri` → `refrigerante`, `feijao` → `feijão`);
3. procurar primeiro a combinação com maior número de ingredientes reconhecidos;
4. usar feedback de combinação menos específica apenas quando não houver correspondência exata;
5. só então recorrer ao feedback individual/regra genérica.

O matching é determinístico e não depende de IA paga. A IA futura poderá ajudar a extrair ingredientes de texto, áudio ou imagem, mas a decisão nutricional continua no catálogo próprio do NutrIA.
