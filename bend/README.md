# HarnessForge Bend — incremento 0.1

Uma base pequena do analisador do [HarnessForge](https://github.com/joicepassos/harness-forge),
para **Linux e macOS**, usando [Bend 2](https://bend-lang.com/).

O core em `core.bend` recebe um inventário de caminhos relativos, identifica
linguagens, manifestos de build e sinais de testes/infraestrutura, conta as
ocorrências e gera Markdown com até três arquivos de evidência por sinal.
O coletor `scan.py` apenas percorre diretórios e entrega o inventário para o
executável Bend. Nenhum arquivo do projeto é aberto para ler seu conteúdo.

## Executar

Pré-requisitos: Git, Bun 1.3.14, Node 24, Python 3.12+ e Clang 14+.
No macOS, instale as ferramentas de linha de comando do Xcode; no Ubuntu,
instale `clang` pelo gerenciador de pacotes.

```sh
git clone https://github.com/joicepassos/harness-forge-bend.git
cd harness-forge-bend
sh bend/build.sh
python3 bend/scan.py /caminho/do/projeto > /tmp/relatorio.md
```

O build baixa o compilador oficial em `.cache/bend`, fixado no commit
`75cb8f3e041aeaad2b37e726c0a33ba19dc49df8` (Bend 2.0.23), verifica as leis,
executa os testes e compila `bend/bin/harnessforge-bend-core`.
Use `BEND_SOURCE=/caminho/bend sh bend/build.sh` para reutilizar um checkout
do mesmo commit. A análise não depende de Go, Node, Bun ou conexão de rede;
depois do build, precisa apenas de Python e do binário Bend.

Guarde o relatório fora do projeto analisado para ele não entrar no inventário
da próxima execução. A saída padrão contém apenas o relatório; erros são
enviados à saída de erro com código diferente de zero.

## Regras deste incremento

- Linguagens por extensão: Bend, Go, Python, Java, TypeScript/TSX,
  JavaScript/JSX, Rust, C e Shell. Comparação diferencia maiúsculas/minúsculas.
- Build por nome do manifesto, incluindo subprojetos: Go modules, npm-compatible,
  Python packaging, Cargo, Maven, Gradle e Make.
- Sinais: arquivos Go de teste, diretório raiz `tests/`, Dockerfile,
  GitHub Actions na raiz, README.md e AGENTS.md.
- Ordem determinística e caminhos escapados nas tabelas Markdown.
- Exclusão de links simbólicos, arquivos especiais, diretórios de dependências,
  caches e alguns nomes sensíveis, como `.env*` e chaves privadas.
- Limites: 20 mil arquivos, 100 mil entradas visitadas, profundidade 64 e
  manifesto UTF-8 de 4 MiB. Exceder limites causa erro, sem relatório parcial.

## Limitações deliberadas

São heurísticas de nomes, sem análise de conteúdo, AST, frameworks, dependências,
histórico Git, IA, geração de instruções ou validação de harness YAML.
Não interpreta `.gitignore`. Binários comuns entram na contagem total de arquivos,
mas seu conteúdo não é lido. A lista de exclusões não é um detector de segredos.
Execute sobre uma árvore estável: esta base não oferece snapshot atômico contra
mudanças concorrentes. Diretórios podados contam como uma entrada excluída.

`LAWS.bend` e `PROOF.bend` verificam quatro propriedades restritas: uma ausência
preserva a contagem, uma presença acrescenta um e inventários vazios não produzem
arquivos nem correspondências. Não são uma prova formal do coletor ou da aplicação
inteira. Os testes cobrem detecção, evidências, limites, exclusões e execução nativa.

## Evolução incremental

1. **Core puro:** regras, contagem, evidências, relatório e leis.
2. **Entrada real:** coletor limitado, CLI Bend e testes de integração.
3. **Validação Linux/macOS:** build fixado e relatório do próprio repositório no CI.

Próximas etapas possíveis: respeitar `.gitignore`, saída JSON e substituir o
coletor por um efeito POSIX em Bend. O código Go herdado permanece como referência;
esta versão não pretende ter paridade completa com ele.
