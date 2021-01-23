// Copyright 2020 IBM Corp.
// SPDX-License-Identifier: Apache-2.0

package mockup

import (
	"github.com/ibm/the-mesh-for-data/pkg/multicluster"
)

// ClusterLister is a mockup cluster manager
type ClusterLister struct {
}

// GetClusters returns the cluster config for testing
func (m *ClusterLister) GetClusters() ([]multicluster.Cluster, error) {
	return []multicluster.Cluster{
		{
			Name:     "US-cluster",
			Metadata: multicluster.ClusterMetadata{Region: "US"},
		},
		{
			Name:     "Germany-cluster",
			Metadata: multicluster.ClusterMetadata{Region: "Germany"},
		},
	}, nil
}
