provider "google" {
  project = "project-1f436c31-1dda-476d-82b"
  region  = "us-central1"
}

# 1. The Template (The Blueprint)
resource "google_compute_instance_template" "lab_template" {
  name_prefix  = "lab-template-"
  machine_type = "e2-micro"

  disk {
    source_image = "debian-cloud/debian-11"
    auto_delete  = true
    boot         = true
  }

  network_interface {
    network = "default"
  }
}

# 2. Three Groups, 1 Instance Each
resource "google_compute_instance_group_manager" "lab_groups" {
  count              = 3
  name               = "learning-group-${count.index}"
  base_instance_name = "lab-node"
  zone               = "us-central1-a"
  target_size        = 3 # 1 VM per group

  version {
    instance_template = google_compute_instance_template.lab_template.id
  }
}



# 4. Verify Output
output "verification_message" {
  value = "Success! Created 3 groups. Check Dashboard: 'Instance Group Size Tracker' in GCP Console."
}
