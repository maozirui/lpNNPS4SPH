#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#define N 1000
#define R_CUT 0.2
#define max_neighbor 1000

__global__ void search_neighbors(double *x, double *y, double *z, int *neighbors, int *num_neighbors) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;

    int count = 0;
    for (int j = 0; j < N; j++) {
        if (i != j) {
            double dx = x[i] - x[j];
            double dy = y[i] - y[j];
            double dz = z[i] - z[j];
            double r = sqrt(dx*dx + dy*dy + dz*dz);
            if (r <= R_CUT) {
                neighbors[i*max_neighbor + count] = j;
                count++;
            }
        }
    }
    num_neighbors[i] = count;
}

int main() {
    double x[N], y[N], z[N];
    int neighbors[N*max_neighbor], num_neighbors[N];
    FILE *fp;

    fp = fopen("coordinates_1000.dat", "r");

    for (int i = 0; i < N; i++) {
        fscanf(fp, "%lf %lf %lf", &x[i], &y[i], &z[i]);
    }

    fclose(fp);

    // for (int i = 0; i < N; i++) {
    //     x[i] = rand() / (double)RAND_MAX;
    //     y[i] = rand() / (double)RAND_MAX;
    //     z[i] = rand() / (double)RAND_MAX;
    // }

    double *d_x, *d_y, *d_z;
    int *d_neighbors, *d_num_neighbors;

    cudaMalloc((void **)&d_x, N*sizeof(double));
    cudaMalloc((void **)&d_y, N*sizeof(double));
    cudaMalloc((void **)&d_z, N*sizeof(double));
    cudaMalloc((void **)&d_neighbors, N*max_neighbor*sizeof(int));
    cudaMalloc((void **)&d_num_neighbors, N*sizeof(int));

    cudaMemcpy(d_x, x, N*sizeof(double), cudaMemcpyHostToDevice);
    cudaMemcpy(d_y, y, N*sizeof(double), cudaMemcpyHostToDevice);
    cudaMemcpy(d_z, z, N*sizeof(double), cudaMemcpyHostToDevice);

    int block_size = 256;
    int grid_size = (N + block_size - 1) / block_size;

    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);
    cudaEventRecord(start);

    for (int i = 0; i < 5000; i++) {
        search_neighbors<<<grid_size, block_size>>>(d_x, d_y, d_z, d_neighbors, d_num_neighbors);
    }

    cudaEventRecord(stop);

    cudaEventSynchronize(stop);
    float elapsed_time_ms;
    cudaEventElapsedTime(&elapsed_time_ms, start, stop);

    

    cudaMemcpy(neighbors, d_neighbors, N*max_neighbor*sizeof(int), cudaMemcpyDeviceToHost);
    cudaMemcpy(num_neighbors, d_num_neighbors, N*sizeof(int), cudaMemcpyDeviceToHost);

    for (int i = N-1; i < N; i++) {
        printf("Particle %d neighbors: ", i);
        for (int j = 0; j < num_neighbors[i]; j++) {
            printf("%d ", neighbors[i*max_neighbor + j]);
        }
        printf("\n");
    }

    printf("Elapsed time: %.3f ms\n", elapsed_time_ms);

    cudaFree(d_x);
    cudaFree(d_y);
    cudaFree(d_z);
    cudaFree(d_neighbors);
    cudaFree(d_num_neighbors);

    return 0;
}
