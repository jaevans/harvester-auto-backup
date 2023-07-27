# Harvester Auto-Backup

Simple script to create backups of labeled VMs in Harvester, and provide smart aging of backups.

harvester-auto-backup scans your harvester cluster looking for for a specific label, and when it finds it on a VM creates a backup of that VM. It then checks the age of any existing backups and deletes them according to the retention policy.

## Requirements

* Harvester cluster with `kubectl` access
* Configured backukp target in Harvester
* Ability to edit the yaml of VMs in Harvester

### Backup Target

A valid backup target must be configured in Harvester. This can be done by following the [Harvester documentation](https://docs.harvesterhci.io/dev/vm/backup-restore#configure-backup-target).

## Installation

Install the CronJob by applying the manifest from this repository:

```bash
kubectl apply -f https://raw.githubusercontent.com/jaevans/harvester-auto-backup/main/deploy.yaml
```

Or download and modify `deploy.yaml` to suit your needs.

## Configuration

`auto-backup` takes the following arguments, specified in the CronJob resource, to configure its behavior:

| Argument | Description | Required | Default |
| --- | --- | --- | --- |
| `--label` | The label to search for on VMs to backup | yes ||
| `--verbose` | Enable verbose logging | no | `false` |
| `--dry-run` | Enable dry-run mode (no backups will be created) | no | `false` |
| `--namespace` | Only search this namespace for VMs to backup (not fully tested) | no | `""` (All namespaces) |

### CronJob

The CronJob is configured to run every night at 02:00 UTC by default. You can modify this by editing the `deploy.yaml` file and changing the CronJob's `spec.schedule` field.

### VM Label

The VM label is configured in the CronJob's `spec.jobTemplate.spec.template.spec.containers[0].args[0]` field. You can modify this by editing the `deploy.yaml` file and changing the field to any valid label you want to use to mark VMs for backup.

### Retention Policy

A "smart" retention policy is applied to existing backups of the VMs. The retention policy is as follows:

* Keep all backups for the past week
* Keep one backup per week for the past 3 months
* Keep one backup per month for the past year
* Delete all backups more than a year old

These thresholds are currently hardcoded in the `auto-backup` script, and can be adjusted by modifying the retention variables `keep_weekly_after`, `keep_monthly_after`, and `delete_after`. All backups yunger than `keep_weekly_after` are kept, weekly backups younger than `keep_monthly_after` are kept, and then monthly backups are kept until `delete_after`.

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.