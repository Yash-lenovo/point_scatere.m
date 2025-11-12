# Field II Single Point Scatterer Simulation

## Description
This MATLAB script simulates ultrasound imaging of a single point scatterer using the Field II ultrasound simulation toolbox. It generates B-mode images and analyzes the Point Spread Function (PSF) to evaluate imaging system performance.

## Prerequisites

### Software Requirements
- **MATLAB** (R2016b or later recommended)
- **Field II Toolbox** (free download)

### Installing Field II
1. Download Field II from the official website: http://field-ii.dk/
2. Extract the downloaded files to a folder (e.g., `C:\Field_II` or `~/Field_II`)
3. Add Field II to your MATLAB path:
   ```matlab
   addpath('path/to/Field_II');
   ```
4. Verify installation by typing `field_init` in MATLAB command window

## Files

- `field_ii_single_point.m` - Main simulation script

## Quick Start

1. **Open MATLAB** and navigate to the script directory
2. **Run the script**:
   ```matlab
   field_ii_single_point
   ```
3. **View results**: The script will display 4 plots showing RF data, envelope, B-mode image, and PSF

## Simulation Parameters

### Transducer Settings
| Parameter | Value | Description |
|-----------|-------|-------------|
| Center Frequency | 5 MHz | Operating frequency |
| Number of Elements | 128 | Array size |
| Element Width | λ/2 | Based on wavelength |
| Element Height | 5 mm | Elevation dimension |
| Sampling Frequency | 100 MHz | Data acquisition rate |

### Imaging Settings
| Parameter | Default Value | Description |
|-----------|---------------|-------------|
| Scan Lines | 128 | Number of A-lines |
| Focal Depth | 40 mm | Transmit/receive focus |
| Depth Range | 20-60 mm | Imaging region |
| Dynamic Range | 60 dB | Display contrast |

### Point Scatterer Position
| Parameter | Default Value | Description |
|-----------|---------------|-------------|
| `point_x` | 0 mm | Lateral position (left/right) |
| `point_y` | 0 mm | Elevation position |
| `point_z` | 40 mm | Depth (axial position) |

## Customization

### Changing Point Location
Edit lines 41-43 in the script:
```matlab
point_x = 0;           % Lateral position [m]
point_y = 0;           % Elevation position [m]
point_z = 40e-3;       % Depth [m] (40 mm)
```

**Examples:**
- Move point 5mm to the right: `point_x = 5e-3;`
- Move point to 30mm depth: `point_z = 30e-3;`
- Off-axis at 3mm: `point_x = 3e-3; point_z = 35e-3;`

### Changing Transducer Frequency
Edit line 15:
```matlab
f0 = 7.5e6;  % Change to 7.5 MHz
```

### Adjusting Image Quality
- **More scan lines** (slower but higher resolution):
  ```matlab
  scan_lines = 256;  % Line 52
  ```
- **Higher dynamic range** (more contrast):
  ```matlab
  dynamic_range = 80;  % Line 82
  ```

### Multiple Point Scatterers
To add more points, modify lines 44-45:
```matlab
phantom_positions = [0, 0, 30e-3;    % Point 1
                     5e-3, 0, 40e-3;  % Point 2
                     -5e-3, 0, 50e-3]; % Point 3
phantom_amplitudes = [1; 1; 1];       % Equal brightness
```

## Output

### Display Windows
The script generates a figure with 4 subplots:

1. **RF Data**: Raw radio-frequency signals before processing
2. **Envelope Detected**: After Hilbert transform envelope detection
3. **B-mode Image**: Final log-compressed ultrasound image with point marked (red cross)
4. **Point Spread Function**: Lateral and axial profiles showing resolution

### Console Output
```
Point scatterer at: x=0.0mm, y=0.0mm, z=40.0mm
Simulating 128 scan lines...
Completed 20/128 lines
...
Lateral FWHM: 0.85 mm
Simulation completed successfully!
```

## Understanding Results

### Point Spread Function (PSF)
- **Lateral FWHM**: Indicates lateral resolution (smaller is better)
- **Typical values**: 0.5-2 mm depending on frequency and focus
- **Sharp PSF**: Good focusing and high resolution
- **Broad PSF**: Poor focusing or off-axis point

### Image Quality Indicators
- **Bright spot**: Point should appear as small bright region
- **Symmetry**: PSF should be symmetric around the point
- **Side lobes**: Faint lines around main point (normal for arrays)

## Troubleshooting

### Error: "Undefined function 'field_init'"
**Solution**: Field II is not installed or not in MATLAB path
```matlab
addpath('path/to/Field_II');
```

### Error: "Out of memory"
**Solution**: Reduce `rf_data` matrix size (line 57):
```matlab
rf_data = zeros(2000, scan_lines);  % Reduce from 4000
```

### Warning: "Image is blank"
**Solution**: Check point position is within imaging range (20-60mm depth by default)

### Simulation is too slow
**Solutions**:
- Reduce scan lines: `scan_lines = 64;`
- Reduce elements: `N_elements = 64;`
- Use fewer samples: `rf_data = zeros(2000, scan_lines);`

## Performance

| Configuration | Approximate Time |
|---------------|------------------|
| Default (128 lines) | 10-30 seconds |
| High-res (256 lines) | 30-60 seconds |
| Low-res (64 lines) | 5-15 seconds |

*Times vary based on computer specifications*

## Applications

This simulation is useful for:
- **Education**: Understanding ultrasound image formation
- **Research**: Testing beamforming algorithms
- **Development**: Validating transducer designs
- **Analysis**: Measuring spatial resolution and PSF
- **Optimization**: Comparing different imaging parameters

## Technical Notes

### Speed of Sound
Default: 1540 m/s (soft tissue average)
- Change in line 17 for different media
- Water: 1480 m/s
- Fat: 1450 m/s
- Muscle: 1580 m/s

### Beamforming
- Uses focused transmit and receive
- Dynamic focusing during receive
- Linear array with electronic steering

### Signal Processing Pipeline
1. **Excitation**: Sine wave pulse generation
2. **Transmission**: Focused acoustic beam
3. **Scattering**: Point reflects ultrasound
4. **Reception**: Array receives echoes
5. **Beamforming**: Coherent summation
6. **Envelope Detection**: Hilbert transform
7. **Log Compression**: Dynamic range reduction

## References

- Field II website: http://field-ii.dk/
- J.A. Jensen: "Field: A Program for Simulating Ultrasound Systems", Medical & Biological Engineering & Computing, 1996
- J.A. Jensen and N. B. Svendsen: "Calculation of pressure fields from arbitrarily shaped, apodized, and excited ultrasound transducers", IEEE Trans. Ultrason., Ferroelec., Freq. Contr., 1992

## License

This script is provided for educational and research purposes. Field II is free for non-commercial use under its own license terms.

## Author & Support

For questions about:
- **Field II toolbox**: Visit http://field-ii.dk/
- **This script**: Check MATLAB documentation or ultrasound imaging textbooks
- **Bugs**: Verify Field II installation and MATLAB version compatibility

## Version History

- **v1.0** (2024): Initial release with single point scatterer simulation

---

**Note**: This simulation requires Field II to be properly installed. Download from http://field-ii.dk/ before running the script.
