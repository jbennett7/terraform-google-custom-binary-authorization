resource "google_container_analysis_note" "note" {
  provider = "google-beta"
  project = var.project_id
  name = "ci-attestor-note"
  attestation_authority {
    hint {
      human_readable_name = "CI ATTESTOR"
    }
  }
}
resource "google_binary_authorization_attestor" "attestor" {
  project = var.project_id
  provider = "google-beta"
  name = var.binauth_name
  attestation_authority_note {
    note_reference = google_container_analysis_note.note.name
    public_keys {
      ascii_armored_pgp_public_key = file("${var.ascii_armored_pgp_public_key_file}")
    }
  }
}
resource "google_binary_authorization_policy" "policy" {
  project = var.project_id
  provider = "google-beta"
  admission_whitelist_patterns {
      name_pattern  = "gcr.io/google_containers/*"
  }
  admission_whitelist_patterns {
      name_pattern  = "k8s.gcr.io/*"
  }
  admission_whitelist_patterns {
      name_pattern  = "gcr.io/stackdriver-agents/*"
  }
  cluster_admission_rules {
    cluster = join(".", [var.region, var.cluster_name])
    evaluation_mode = "REQUIRE_ATTESTATION"
    #enforcement_mode = "ENFORCED_BLOCK_AND_AUDIT_LOG"
    enforcement_mode = "DRYRUN_AUDIT_LOG_ONLY"
    require_attestations_by = ["${google_binary_authorization_attestor.attestor.name}"]
  }
  default_admission_rule {
    evaluation_mode = "ALWAYS_DENY"
    enforcement_mode = "DRYRUN_AUDIT_LOG_ONLY"
    # enforcement_mode = "ENFORCED_BLOCK_AND_AUDIT_LOG"
  }

}
