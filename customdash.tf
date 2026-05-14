
resource "google_monitoring_dashboard" "mig_status_dashboard_v2" {
  project = local.project_id
  dashboard_json = jsonencode({
    displayName = "MIG Operational Overview - v2"
    gridLayout = {
      columns = 1
      widgets = [
        {
          title = "Instance Group Status: Current vs Target"
          timeSeriesTable = {
            dataSets = [
              {
                tableTemplate = "CURRENT_SIZE"
                timeSeriesQuery = {
                  timeSeriesFilter = {
                    filter = "metric.type=\"compute.googleapis.com/instance_group/size\" resource.type=\"instance_group\" metric.label.instance_state=\"running\""
                    aggregation = {
                      perSeriesAligner   = "ALIGN_MEAN"
                      crossSeriesReducer = "REDUCE_SUM"
                      alignmentPeriod    = "60s"
                      groupByFields      = ["resource.label.instance_group_name"]
                    }
                  }
                }
              },
              {
                tableTemplate = "TARGET_SIZE"
                timeSeriesQuery = {
                  timeSeriesFilter = {
                    filter = "metric.type=\"compute.googleapis.com/instance_group/size\" resource.type=\"instance_group\""
                    aggregation = {
                      perSeriesAligner   = "ALIGN_SUM"
                      crossSeriesReducer = "REDUCE_SUM"
                      alignmentPeriod    = "60s"
                      groupByFields      = ["resource.label.instance_group_name"]
                    }
                  }
                }
              }
            ]
            metricVisualization = "NUMBER"
            columnSettings = [
              {
                column      = "resource.label.instance_group_name"
                displayName = "NAME"
              },
            {
                column =  "CURRENT_SIZE",
                displayName = "Current (Running)"
            },
            {
                column =  "TARGET_SIZE",
                displayName = "Target (Total)"
            }
            ]
          }
        }
      ]
    }
  })
}


resource "google_monitoring_dashboard" "mig_status_dashboard_final" {
  project = local.project_id
  dashboard_json = jsonencode({
    displayName = "MIG Operational Overview - Final"
    gridLayout = {
      columns = 1
      widgets = [
        {
          title = "Instance Group Status: Current vs Target"
          timeSeriesTable = {
            dataSets = [
              {
                tableTemplate = "RUNNING_COUNT"
                timeSeriesQuery = {
                  # MQL allows us to explicitly drop the 'instance_state' label 
                  # that was causing your rows to split.
                  timeSeriesQueryLanguage = <<-EOT
                    fetch instance_group

                    | metric 'compute.googleapis.com/instance_group/size'
                    | filter (metric.instance_state == 'running')
                    | group_by [resource.instance_group_name], [val: sum(value.size)]

                    | align mean(1m)
                    | every 1m
                  EOT
                }
              },
              {
                tableTemplate = "TOTAL_TARGET"
                timeSeriesQuery = {
                  timeSeriesQueryLanguage = <<-EOT
                    fetch instance_group

                    | metric 'compute.googleapis.com/instance_group/size'
                    | group_by [resource.instance_group_name], [val: sum(value.size)]
                    | align mean(1m)
                    | every 1m
                  EOT
                }
              }
            ]
            metricVisualization = "NUMBER"
            columnSettings = [
              {
                column      = "resource.instance_group_name"
                displayName = "NAME"
              },
              {
                column      = "RUNNING_COUNT"
                displayName = "Current (Running)"
              },
              {
                column      = "TOTAL_TARGET"
                displayName = "Target (Total)"
              }
            ]
          }
        }
      ]
    }
  })
}
