

locals {
  project_id = "project-1f436c31-1dda-476d-82b"
}


resource "google_monitoring_dashboard" "lab_dashboard" {
  project = local.project_id
  dashboard_json = <<EOF
{
  "displayName": "Instance Group Command Center",
  "gridLayout": {
    "columns": 2,
    "widgets": [
      {
        "title": "Total Active Instances",
        "scorecard": {
          "timeSeriesQuery": {
            "timeSeriesFilter": {
              "filter": "metric.type=\"compute.googleapis.com/instance_group/size\" resource.type=\"instance_group\"",
              "aggregation": {
                "perSeriesAligner": "ALIGN_MEAN",
                "crossSeriesReducer": "REDUCE_SUM",
                "alignmentPeriod": "60s"
              }
            }
          },
          "thresholds": [
            {
              "label": "Critical Low",
              "value": 1,
              "color": "RED",
              "direction": "BELOW"
            }
          ]
        }
      },
      {
        "title": "Group Status Table",
        "timeSeriesTable": {
          "dataSets": [
            {
              "tableTemplate": "Current Size",
              "timeSeriesQuery": {
                "timeSeriesFilter": {
                  "filter": "metric.type=\"compute.googleapis.com/instance_group/size\" resource.type=\"instance_group\"",
                  "aggregation": { 
                    "perSeriesAligner": "ALIGN_MEAN",
                    "crossSeriesReducer": "REDUCE_SUM",
                    "groupByFields": ["metric.label.instance_state"]
                  }
                }
              }
            },
            {
              "tableTemplate": "Target Size",
              "timeSeriesQuery": {
                "timeSeriesFilter": {
                  "filter": "metric.type=\"compute.googleapis.com/instance_group/size\" resource.type=\"instance_group\"",
                  "aggregation": { 
                    "perSeriesAligner": "ALIGN_MEAN", 
                    "crossSeriesReducer": "REDUCE_SUM",
                    "groupByFields": ["metric.label.instance_state"]
                  }
                }
              }
            }
          ],
          "columnSettings": [
            {
              "column": "metric.label.instance_state",
              "displayName": "Vm Instances"
            }
          ],
          "metricVisualization": "NUMBER"
        }
      },
      {
        "title": "Instance Group Events",
        "logsPanel": {
         
          "filter": "resource.type=\"instance_group\" OR resource.type=\"gce_instance_group_manager\"",
          "resourceNames": ["projects/${local.project_id}"]
        }
      }
    ]
  }
}
EOF
}

#--------------

resource "google_monitoring_dashboard" "group_size_dashboard" {
  project = local.project_id

  #The replace function strips out the \r (carriage return) characters
  dashboard_json = replace(<<-EOF
{
  "displayName": "Instance Group Status Table Detailed",
  "gridLayout": {
    "columns": 1,
    "widgets": [
      {
        "title": "Group Size Breakdown",
        "timeSeriesTable": {
          "dataSets": [
            {
              "timeSeriesQuery": {
                "timeSeriesFilter": {
                  "filter": "metric.type=\"compute.googleapis.com/instance_group/size\" resource.type=\"instance_group\" resource.label.project_id=\"${local.project_id}\"",
                  "aggregation": {
                    "perSeriesAligner": "ALIGN_MEAN",
                    "crossSeriesReducer": "REDUCE_SUM",
                    "groupByFields": [
                      "metric.label.instance_state"
                    ]
                  }
                }
              }
            }
          ]
        }
      }
    ]
  }
}
EOF
  , "\r", "")
}

