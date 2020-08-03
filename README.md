# ADR reindexer

This action reindexes ADRs to ensure a pull request can be merged cleanly into a target branch without any conflicting numbers.

## Usage

```yaml
- uses: sjdaws/adr-reindexer@master
  with:
    # The branch to compare the current branch against
    targetBranch: master
    
    # The title to use for the table of contents
    tocTitle: "Architecture Decision Records"
```