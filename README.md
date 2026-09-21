# HarnessForge Bend

[![Bend core](https://github.com/joicepassos/harness-forge-bend/actions/workflows/bend.yml/badge.svg)](https://github.com/joicepassos/harness-forge-bend/actions/workflows/bend.yml)

Uma versão experimental e incremental do core de análise do
[HarnessForge](https://github.com/joicepassos/harness-forge), escrita em
[Bend 2](https://bend-lang.com/), para **Linux e macOS**.

Analisa os nomes dos arquivos de um projeto e produz um relatório Markdown com
linguagens, manifestos de build, sinais de testes e evidências. O projeto analisado
não é alterado e nenhum comando dele é executado.

## Começar

Instale Git, Bun 1.3.14, Node 24, Python 3.12+ e Clang 14+.

```sh
git clone https://github.com/joicepassos/harness-forge-bend.git
cd harness-forge-bend
sh bend/build.sh
python3 bend/scan.py /caminho/do/projeto > /tmp/relatorio.md
```

O build usa um commit fixo do compilador oficial, verifica quatro leis formais,
executa testes e gera o binário nativo. Depois dele, a análise requer apenas
Python e o binário Bend.

## O que existe nesta base

- **Bend:** classificação, contagens, evidências, relatório e CLI que lê o inventário.
- **Python:** pequeno adaptador para coletar caminhos com exclusões e limites.
- **Validação:** testes do core, coletor e integração nativa em Linux/macOS.

Não é um port completo: não há IA, análise de conteúdo/AST, geração de instruções
ou interpretação de `.gitignore`. As leis cobrem propriedades da contagem;
não provam a aplicação inteira. Leia o [guia do incremento 0.1](bend/README.md)
para detalhes, limites e próximos passos.

O histórico e o código Go foram mantidos como referência da origem. A implementação
nova fica em `bend/`; os instaladores e o pacote npm herdados pertencem ao projeto Go.
Consulte o [README original arquivado](docs/UPSTREAM_README.md) para esse contexto.

Licença [MIT](LICENSE).
