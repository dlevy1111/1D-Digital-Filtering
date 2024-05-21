import numpy as np 
import matplotlib.pyplot as plt 
import json 

def sinc_hamming_LPF(fc, fs, order):
    normalized_fc = fc/ (fs/2)

    #Creates a time vector centered as 0 
    n_temp = np.arange(order) - (order - 1)/2

    #Ideal sinc filter
    h = np.sinc(2 * normalized_fc * n_temp)

    hamming_window = np.hamming(order)
    h *= hamming_window

    h /= np.sum(h)

    return h

if __name__ == "__main__":
    fc =   1e3
    # fs =   10 * fc
    fs = 100e3
    order = 20

    filter_coefficients = sinc_hamming_LPF(fc, fs, order)

    frequency = np.fft.fftfreq(order, 1/fs)
    response = np.fft.fft(filter_coefficients)

#Find the half way to allow just looking at positive frequencies 
    half_point = len(frequency) // 2
    frequency = frequency[:half_point]
    response = np.abs(response[:half_point])
        
    with open('filter_coefficients.txt', 'w') as filehandle: 
        json.dump(filter_coefficients.tolist(), filehandle)

    plt.figure(figsize = (12,8))
    plt.subplot(1,2,1)
    plt.stem(filter_coefficients)
    plt.title('Impulse Response')
    plt.xlabel('Samples')
    plt.grid(True)

    plt.subplot(1,2,2)
    plt.plot(frequency, 20 * np.log10(response))
    # plt.xlim([0,6e3])
    # plt.ylim([-60, 1])
    plt.title('Frequncy Response')
    plt.xlabel('Frequency (Hz)')
    plt.ylabel('Magnitude (dB)')
    plt.grid(True)

    plt.tight_layout()
    plt.show()
