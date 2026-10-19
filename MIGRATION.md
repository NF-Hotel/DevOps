# Migration from NF-Hotel/NFHotel

This repository took over the infrastructure and operations work of NF Hotel from `NF-Hotel/NFHotel` (ADR-0012, MIL-025). This file is the provenance record. No history was rewritten and no commit was made up. The history of how each file was written stays in NFHotel, at the commits listed below.

## Source

- Repository: `NF-Hotel/NFHotel`
- Commit: [`0f69a52`](https://github.com/NF-Hotel/NFHotel/commit/0f69a52a3d2708ffeb01191f01a3b8eb278f9ea4) (`0f69a52a3d2708ffeb01191f01a3b8eb278f9ea4`), the head of PR #150. That commit contains `main` at `82ad362` plus the unmerged work of PR #117 (MIL-021) and PR #150 (MIL-024).
- Method: `git -c core.autocrlf=false archive 0f69a52 <paths> | tar -x`, then a SHA-256 comparison of every copy with the source blob. All 80 files matched before any change.
- Archive refs: the tags `archive/mil-021-secure-cicd-foundation` and `archive/mil-024-postgresql-api-readiness` in NFHotel keep the commits of the two pull requests reachable after they are closed.

## Files copied

The first commit of the migration pull request holds the copies byte for byte. The commits after it change them for this repository, as listed in "Changes after the copy". "Last commit" is the last NFHotel commit that touched the file before the copy.

| Source path (NFHotel) | Path here | Origin | Last commit | SHA-256 (first 16) |
| --- | --- | --- | --- | --- |
| `.editorconfig` | `.editorconfig` | on NFHotel `main` | [9b18534](https://github.com/NF-Hotel/NFHotel/commit/9b18534) | `e56c1be40e2bdb53` |
| `.yamllint` | `.yamllint` | on NFHotel `main` | [b690b57](https://github.com/NF-Hotel/NFHotel/commit/b690b57) | `0da1595ed320eb43` |
| `deploy.env.example` | `deploy.env.example` | on NFHotel `main` | [0aa243e](https://github.com/NF-Hotel/NFHotel/commit/0aa243e) | `f2026ad94cdbfc40` |
| `deploy/benchmark/Dockerfile` | `deploy/benchmark/Dockerfile` | on NFHotel `main` | [b582bbe](https://github.com/NF-Hotel/NFHotel/commit/b582bbe) | `d0a333886aa94bf7` |
| `deploy/benchmark/benchmark.env.example` | `deploy/benchmark/benchmark.env.example` | on NFHotel `main` | [0aa243e](https://github.com/NF-Hotel/NFHotel/commit/0aa243e) | `643e5bde388d4820` |
| `deploy/benchmark/docker-compose.yml` | `deploy/benchmark/docker-compose.yml` | on NFHotel `main` | [732e675](https://github.com/NF-Hotel/NFHotel/commit/732e675) | `858a112ba4b7cb0f` |
| `deploy/benchmark/requirements.lock` | `deploy/benchmark/requirements.lock` | on NFHotel `main` | [b582bbe](https://github.com/NF-Hotel/NFHotel/commit/b582bbe) | `efea1ad532566a78` |
| `deploy/market-analysis/Dockerfile` | `deploy/market-analysis/Dockerfile` | on NFHotel `main` | [a9ae606](https://github.com/NF-Hotel/NFHotel/commit/a9ae606) | `6902e1bb8c075cb7` |
| `deploy/market-analysis/README.md` | `deploy/market-analysis/README.md` | on NFHotel `main` | [0fa84f7](https://github.com/NF-Hotel/NFHotel/commit/0fa84f7) | `c9e3a0d4f02e8a47` |
| `deploy/market-analysis/docker-compose.yml` | `deploy/market-analysis/docker-compose.yml` | on NFHotel `main` | [732e675](https://github.com/NF-Hotel/NFHotel/commit/732e675) | `d35f5bd82c8cdd33` |
| `deploy/market-analysis/market-analysis.env.example` | `deploy/market-analysis/market-analysis.env.example` | on NFHotel `main` | [0aa243e](https://github.com/NF-Hotel/NFHotel/commit/0aa243e) | `db0280a6245b1232` |
| `deploy/market-analysis/market-analysis.toml.example` | `deploy/market-analysis/market-analysis.toml.example` | on NFHotel `main` | [0aa243e](https://github.com/NF-Hotel/NFHotel/commit/0aa243e) | `e0bf85199857013e` |
| `deploy/nfhotel-api/docker-compose.yml` | `deploy/nfhotel-api/docker-compose.yml` | on NFHotel `main` | [732e675](https://github.com/NF-Hotel/NFHotel/commit/732e675) | `500413c4d1bbbef0` |
| `deploy/nfhotel-api/nfhotel-api.env.example` | `deploy/nfhotel-api/nfhotel-api.env.example` | on NFHotel `main` | [f732342](https://github.com/NF-Hotel/NFHotel/commit/f732342) | `953ed9d1dc52c584` |
| `deploy/nfhotel-web/docker-compose.yml` | `deploy/nfhotel-web/docker-compose.yml` | on NFHotel `main` | [732e675](https://github.com/NF-Hotel/NFHotel/commit/732e675) | `83412414f6ae0d09` |
| `deploy/nfhotel-web/nfhotel-web.env.example` | `deploy/nfhotel-web/nfhotel-web.env.example` | on NFHotel `main` | [065c6e8](https://github.com/NF-Hotel/NFHotel/commit/065c6e8) | `c73fb4d394acda78` |
| `deploy/nginx/docker-compose.yml` | `deploy/nginx/docker-compose.yml` | on NFHotel `main` | [4faea51](https://github.com/NF-Hotel/NFHotel/commit/4faea51) | `0224f8da2ac3c13f` |
| `deploy/nginx/nginx.env.example` | `deploy/nginx/nginx.env.example` | on NFHotel `main` | [065c6e8](https://github.com/NF-Hotel/NFHotel/commit/065c6e8) | `8ef9c934c4f33fdf` |
| `deploy/nginx/optional/api.conf` | `deploy/nginx/optional/api.conf` | PR #150 (MIL-024) | [e3a9fca](https://github.com/NF-Hotel/NFHotel/commit/e3a9fca) | `743b47a6c279bb00` |
| `deploy/nginx/snippets/locations.d/README.md` | `deploy/nginx/snippets/locations.d/README.md` | PR #150 (MIL-024) | [fa755b6](https://github.com/NF-Hotel/NFHotel/commit/fa755b6) | `786908c055950b82` |
| `deploy/nginx/snippets/proxy.conf` | `deploy/nginx/snippets/proxy.conf` | on NFHotel `main` | [469c395](https://github.com/NF-Hotel/NFHotel/commit/469c395) | `304ee7cd36733e01` |
| `deploy/nginx/snippets/tls.conf` | `deploy/nginx/snippets/tls.conf` | on NFHotel `main` | [065c6e8](https://github.com/NF-Hotel/NFHotel/commit/065c6e8) | `0df0be53c4271cd0` |
| `deploy/nginx/templates/00-upgrade.conf.template` | `deploy/nginx/templates/00-upgrade.conf.template` | on NFHotel `main` | [469c395](https://github.com/NF-Hotel/NFHotel/commit/469c395) | `9ab142a715c41829` |
| `deploy/nginx/templates/benchmark.conf.template` | `deploy/nginx/templates/benchmark.conf.template` | on NFHotel `main` | [0aa243e](https://github.com/NF-Hotel/NFHotel/commit/0aa243e) | `6694e8151f6b5773` |
| `deploy/nginx/templates/default.conf.template` | `deploy/nginx/templates/default.conf.template` | on NFHotel `main` | [fa755b6](https://github.com/NF-Hotel/NFHotel/commit/fa755b6) | `663716026c9090cb` |
| `deploy/nginx/templates/market-analysis.conf.template` | `deploy/nginx/templates/market-analysis.conf.template` | on NFHotel `main` | [0aa243e](https://github.com/NF-Hotel/NFHotel/commit/0aa243e) | `b68a1ea57df3800a` |
| `deploy/ollama/docker-compose.yml` | `deploy/ollama/docker-compose.yml` | on NFHotel `main` | [0aa243e](https://github.com/NF-Hotel/NFHotel/commit/0aa243e) | `774c4e4ba9e36a20` |
| `deploy/ollama/ollama.env.example` | `deploy/ollama/ollama.env.example` | on NFHotel `main` | [0aa243e](https://github.com/NF-Hotel/NFHotel/commit/0aa243e) | `de7f9ce0bcedf3df` |
| `deploy/postgres/docker-compose.yml` | `deploy/postgres/docker-compose.yml` | on NFHotel `main` | [0aa243e](https://github.com/NF-Hotel/NFHotel/commit/0aa243e) | `e786a412eba87e67` |
| `deploy/postgres/postgres.env.example` | `deploy/postgres/postgres.env.example` | on NFHotel `main` | [0aa243e](https://github.com/NF-Hotel/NFHotel/commit/0aa243e) | `3186a2624f7007bf` |
| `deploy/proxmox/docker-compose.yml` | `deploy/proxmox/docker-compose.yml` | on NFHotel `main` | [355b592](https://github.com/NF-Hotel/NFHotel/commit/355b592) | `70f4a567acc9c467` |
| `deploy/systemd/nfhotel-backup.service` | `deploy/systemd/nfhotel-backup.service` | PR #117 (MIL-021) | [6cd89c1](https://github.com/NF-Hotel/NFHotel/commit/6cd89c1) | `095ab48249359daf` |
| `deploy/systemd/nfhotel-backup.timer` | `deploy/systemd/nfhotel-backup.timer` | PR #117 (MIL-021) | [d6025b4](https://github.com/NF-Hotel/NFHotel/commit/d6025b4) | `771e122a88a85618` |
| `docs/adr/adr-0007-cicd-and-supply-chain.md` | `docs/adr/adr-0007-cicd-and-supply-chain.md` | PR #117 (MIL-021) | [064c27c](https://github.com/NF-Hotel/NFHotel/commit/064c27c) | `774c8357d670d9f2` |
| `docs/adr/adr-0008-database-migration-and-backup.md` | `docs/adr/adr-0008-database-migration-and-backup.md` | PR #117 (MIL-021) | [064c27c](https://github.com/NF-Hotel/NFHotel/commit/064c27c) | `4a15b46a17c9d633` |
| `docs/adr/adr-0009-tls-certificates.md` | `docs/adr/adr-0009-tls-certificates.md` | PR #117 (MIL-021) | [cda15b9](https://github.com/NF-Hotel/NFHotel/commit/cda15b9) | `4db6b52ebb07ebff` |
| `docs/adr/adr-0010-production-vm-as-deployed.md` | `docs/adr/adr-0010-production-vm-as-deployed.md` | PR #117 (MIL-021) | [b0c0285](https://github.com/NF-Hotel/NFHotel/commit/b0c0285) | `92119328519491d5` |
| `docs/adr/adr-0011-postgresql-access-for-the-api.md` | `docs/adr/adr-0011-postgresql-access-for-the-api.md` | PR #150 (MIL-024) | [0f69a52](https://github.com/NF-Hotel/NFHotel/commit/0f69a52) | `0cecc975d0c51407` |
| `docs/milestones/mil-021-secure-cicd-foundation.md` | `docs/milestones/mil-021-secure-cicd-foundation.md` | PR #117 (MIL-021) | [b0c0285](https://github.com/NF-Hotel/NFHotel/commit/b0c0285) | `03fe888cf946d504` |
| `docs/milestones/mil-022-supply-chain-security.md` | `docs/milestones/mil-022-supply-chain-security.md` | PR #117 (MIL-021) | [064c27c](https://github.com/NF-Hotel/NFHotel/commit/064c27c) | `91a62f997a02e61f` |
| `docs/milestones/mil-023-operational-quality.md` | `docs/milestones/mil-023-operational-quality.md` | PR #117 (MIL-021) | [064c27c](https://github.com/NF-Hotel/NFHotel/commit/064c27c) | `7f663611624027e3` |
| `docs/milestones/mil-024-postgresql-api-readiness.md` | `docs/milestones/mil-024-postgresql-api-readiness.md` | PR #150 (MIL-024) | [0f69a52](https://github.com/NF-Hotel/NFHotel/commit/0f69a52) | `7e523df716b5338f` |
| `docs/sqa/devsecops-assessment.md` | `docs/sqa/devsecops-assessment.md` | PR #117 (MIL-021) | [b0c0285](https://github.com/NF-Hotel/NFHotel/commit/b0c0285) | `fe0ee411ccc29da6` |
| `docs/sqa/reviews/rc-089-milestone-021.md` | `docs/sqa/reviews/rc-089-milestone-021.md` | PR #117 (MIL-021) | [2da65f6](https://github.com/NF-Hotel/NFHotel/commit/2da65f6) | `17554d10e9dbc3b7` |
| `docs/sqa/reviews/rc-090-milestone-022.md` | `docs/sqa/reviews/rc-090-milestone-022.md` | PR #117 (MIL-021) | [2da65f6](https://github.com/NF-Hotel/NFHotel/commit/2da65f6) | `d248eb29a14eb8b8` |
| `docs/sqa/reviews/rc-091-milestone-023.md` | `docs/sqa/reviews/rc-091-milestone-023.md` | PR #117 (MIL-021) | [2da65f6](https://github.com/NF-Hotel/NFHotel/commit/2da65f6) | `1bff29cde125b6d8` |
| `docs/sqa/reviews/rc-092-adr-0007.md` | `docs/sqa/reviews/rc-092-adr-0007.md` | PR #117 (MIL-021) | [064c27c](https://github.com/NF-Hotel/NFHotel/commit/064c27c) | `2f15a9e472b771f7` |
| `docs/sqa/reviews/rc-093-adr-0008.md` | `docs/sqa/reviews/rc-093-adr-0008.md` | PR #117 (MIL-021) | [064c27c](https://github.com/NF-Hotel/NFHotel/commit/064c27c) | `937ec6af29ea7e2b` |
| `docs/sqa/reviews/rc-094-mil-021-shell-code.md` | `docs/sqa/reviews/rc-094-mil-021-shell-code.md` | PR #117 (MIL-021) | [cda15b9](https://github.com/NF-Hotel/NFHotel/commit/cda15b9) | `19cde9a0b43d6f5e` |
| `docs/sqa/reviews/rc-095-mil-021-workflows.md` | `docs/sqa/reviews/rc-095-mil-021-workflows.md` | PR #117 (MIL-021) | [cda15b9](https://github.com/NF-Hotel/NFHotel/commit/cda15b9) | `660cad95d6d5cf15` |
| `docs/sqa/reviews/rc-096-adr-0009.md` | `docs/sqa/reviews/rc-096-adr-0009.md` | PR #117 (MIL-021) | [cda15b9](https://github.com/NF-Hotel/NFHotel/commit/cda15b9) | `4fd1963707898cbe` |
| `docs/sqa/reviews/rc-097-milestone-021-reconciliation.md` | `docs/sqa/reviews/rc-097-milestone-021-reconciliation.md` | PR #117 (MIL-021) | [b0c0285](https://github.com/NF-Hotel/NFHotel/commit/b0c0285) | `fae207a575afd918` |
| `docs/sqa/reviews/rc-098-adr-0010.md` | `docs/sqa/reviews/rc-098-adr-0010.md` | PR #117 (MIL-021) | [b0c0285](https://github.com/NF-Hotel/NFHotel/commit/b0c0285) | `d60c234869451efc` |
| `docs/sqa/reviews/rc-099-milestone-024.md` | `docs/sqa/reviews/rc-099-milestone-024.md` | PR #150 (MIL-024) | [0f69a52](https://github.com/NF-Hotel/NFHotel/commit/0f69a52) | `9543079ff241d6f2` |
| `docs/sqa/reviews/rc-100-adr-0011.md` | `docs/sqa/reviews/rc-100-adr-0011.md` | PR #150 (MIL-024) | [0f69a52](https://github.com/NF-Hotel/NFHotel/commit/0f69a52) | `5729b47094e5467a` |
| `docs/sqa/reviews/rc-101-mil-024-code-and-gate.md` | `docs/sqa/reviews/rc-101-mil-024-code-and-gate.md` | PR #150 (MIL-024) | [0f69a52](https://github.com/NF-Hotel/NFHotel/commit/0f69a52) | `7f09dfb25ce3bf77` |
| `docs/wiki/CI-CD.md` | `docs/wiki/CI-CD.md` | PR #117 (MIL-021) | [1b94761](https://github.com/NF-Hotel/NFHotel/commit/1b94761) | `8c50f0462358086f` |
| `docs/wiki/Database-Preparation.md` | `docs/wiki/Database-Preparation.md` | PR #150 (MIL-024) | [891129b](https://github.com/NF-Hotel/NFHotel/commit/891129b) | `ba12b52e73d4bca7` |
| `docs/wiki/Proxmox-Deployment.md` | `docs/wiki/Proxmox-Deployment.md` | on NFHotel `main` | [065c6e8](https://github.com/NF-Hotel/NFHotel/commit/065c6e8) | `b6dc5b6c8110dd26` |
| `pve.env.example` | `pve.env.example` | on NFHotel `main` | [355b592](https://github.com/NF-Hotel/NFHotel/commit/355b592) | `be5e5e5a19eca16a` |
| `scripts/backup-database.sh` | `scripts/backup-database.sh` | PR #117 (MIL-021) | [fa755b6](https://github.com/NF-Hotel/NFHotel/commit/fa755b6) | `451a9a4977b3ab65` |
| `scripts/build-release-images.sh` | `scripts/build-release-images.sh` | PR #117 (MIL-021) | [6cd89c1](https://github.com/NF-Hotel/NFHotel/commit/6cd89c1) | `4e25e23882b2b72e` |
| `scripts/cd-steps.sh` | `scripts/cd-steps.sh` | PR #117 (MIL-021) | [6cd89c1](https://github.com/NF-Hotel/NFHotel/commit/6cd89c1) | `1ed04dc82b3bfe0b` |
| `scripts/check-tailnet-exposure.sh` | `scripts/check-tailnet-exposure.sh` | PR #150 (MIL-024) | [891129b](https://github.com/NF-Hotel/NFHotel/commit/891129b) | `e9b89612ed398b15` |
| `scripts/create-docker-vm.sh` | `scripts/create-docker-vm.sh` | on NFHotel `main` | [0aa243e](https://github.com/NF-Hotel/NFHotel/commit/0aa243e) | `73a9ab0d2a72c097` |
| `scripts/db/roles.sql` | `scripts/db/roles.sql` | PR #150 (MIL-024) | [fa755b6](https://github.com/NF-Hotel/NFHotel/commit/fa755b6) | `23413a44cac11789` |
| `scripts/db/transfer-ownership.sql` | `scripts/db/transfer-ownership.sql` | PR #150 (MIL-024) | [fa755b6](https://github.com/NF-Hotel/NFHotel/commit/fa755b6) | `6e2ed95fc6f9869d` |
| `scripts/deploy-release.sh` | `scripts/deploy-release.sh` | PR #117 (MIL-021) | [1b94761](https://github.com/NF-Hotel/NFHotel/commit/1b94761) | `4366a9c62119b95c` |
| `scripts/deploy-services.sh` | `scripts/deploy-services.sh` | on NFHotel `main` | [065c6e8](https://github.com/NF-Hotel/NFHotel/commit/065c6e8) | `7f16a04f0084c5b1` |
| `scripts/deploy.sh` | `scripts/deploy.sh` | on NFHotel `main` | [aa6e6ad](https://github.com/NF-Hotel/NFHotel/commit/aa6e6ad) | `741b32e3f8584cc4` |
| `scripts/install-backup.sh` | `scripts/install-backup.sh` | PR #117 (MIL-021) | [6cd89c1](https://github.com/NF-Hotel/NFHotel/commit/6cd89c1) | `84fa914db5a7019c` |
| `scripts/install-deploy-user.sh` | `scripts/install-deploy-user.sh` | PR #117 (MIL-021) | [6cd89c1](https://github.com/NF-Hotel/NFHotel/commit/6cd89c1) | `cfd648aa6061330e` |
| `scripts/lib/common.sh` | `scripts/lib/common.sh` | PR #117 (MIL-021) | [6cd89c1](https://github.com/NF-Hotel/NFHotel/commit/6cd89c1) | `580229ee084f695f` |
| `scripts/make-dev-certificate.sh` | `scripts/make-dev-certificate.sh` | on NFHotel `main` | [065c6e8](https://github.com/NF-Hotel/NFHotel/commit/065c6e8) | `ae29176695e351e9` |
| `scripts/prepare-database-roles.sh` | `scripts/prepare-database-roles.sh` | PR #150 (MIL-024) | [fa755b6](https://github.com/NF-Hotel/NFHotel/commit/fa755b6) | `f740038d6baab216` |
| `scripts/pve-token.sh` | `scripts/pve-token.sh` | on NFHotel `main` | [355b592](https://github.com/NF-Hotel/NFHotel/commit/355b592) | `f89eadb3955950f7` |
| `scripts/restore-drill.sh` | `scripts/restore-drill.sh` | PR #117 (MIL-021) | [5670ba3](https://github.com/NF-Hotel/NFHotel/commit/5670ba3) | `686bf486a08995fb` |
| `scripts/run-proxmox-tests.sh` | `scripts/run-proxmox-tests.sh` | on NFHotel `main` | [91483eb](https://github.com/NF-Hotel/NFHotel/commit/91483eb) | `1c6bb2906da91668` |
| `scripts/test-compose-proxy.sh` | `scripts/test-compose-proxy.sh` | on NFHotel `main` | [065c6e8](https://github.com/NF-Hotel/NFHotel/commit/065c6e8) | `04a3a9854a7f00f6` |
| `scripts/verify-database.sh` | `scripts/verify-database.sh` | PR #150 (MIL-024) | [fa755b6](https://github.com/NF-Hotel/NFHotel/commit/fa755b6) | `4c48f662db4d3cd3` |

## Not copied, and why

| NFHotel path | Stays because | Moves when |
| --- | --- | --- |
| `src/`, `tests/` (except below), `Dockerfile`, `Dockerfile.api`, `NFHotel.sln`, EF Core migrations | Application (ADR-0012 decision 1); the Dockerfiles are shared and reviewed by DevOps through CODEOWNERS | — |
| `.github/workflows/ci.yaml` (PR #22) | The application CI and the required checks of NFHotel | — |
| `.github/workflows/release.yaml`, `cd.yaml` (PR #117) | Entry points: triggers, permissions, environment and OIDC must stay in NFHotel. Their steps moved here as `.github/actions/release-images` and `.github/actions/deploy-release` | — |
| `tests/NFHotel.Proxmox.Tests` | A .NET project in `NFHotel.sln`, built with the solution's `Directory.Build.props` and `global.json` | MIL-025 task 7, with a solution of its own here |
| `docs/business-case.md`, `docs/project-plan.md`, `docs/stakeholder-analysis.md`, `docs/sqa/reviews/rc-088-business-case-cicd.md` | The project baseline; objectives 23 to 25 point here | — |
| `docs/adr/adr-0003`, `adr-0006`, `docs/milestones/mil-001` to `mil-004`, `mil-017`, and their review records | Accepted and completed on NFHotel `main`; kept where they were accepted, and referred to from here | — |
| `SECURITY.md`, `.github/CODEOWNERS` (PR #117) | Repository-specific; this repository has its own | — |

## Changes after the copy

Listed in the commits of the migration pull request, each with its reason:
- relative links to documents that stay in NFHotel become absolute;
- the literal CR bytes in `scripts/deploy-services.sh` are written `\r`, as `7b8cf85` did on PR #22;
- `deploy-release.sh` checks out this repository on the VM;
- the release manifest records the commit of this repository;
- the compose files build from an NFHotel checkout.

## Copies left in NFHotel

The infrastructure files on NFHotel `main` stay there until the first deploy from this repository is verified. They are then removed by a reviewed pull request (MIL-025 task 7). Until then, **edit them here only**.
