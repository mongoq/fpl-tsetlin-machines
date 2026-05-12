#include <stdio.h>
#include "trained_votes.h"
#include "pixel_data.h"

int main() {
    printf("\nMy first little Green Tsetlin Machine ;-)\n\n");
    int y_hat = predict_tm(data);
    printf("Prediction of data in pixel_data.h: %d\n", y_hat);
    return 0;
};
