# 🚀 Rocket Turbopump Axial Turbine Blade Generation (Rocket-TATG)

### 🎥 Demo Video
https://github.com/user-attachments/assets/30c69a11-3bee-4256-a14c-0b8584e8ba17


## ✨ Overview
A MATLAB App Designer tool for **2-stage axial rocket turbine sizing** with **stator/rotor aerofoil plots** and a **3D shaded blade-row visualisation**.

## 🧠 Model Explained
### 📚 Theory
- Meanline turbine analysis
- Energy transfer (euler turbine principle)
- Velocity triangles
- Compressible-flow relations
- Mass continuity
- Choking checks

### ⚙️ Main Assumptions
- Ideal-gas behaviour
- Constant gas properties
- Quasi-one-dimensional meanline flow
- Some losses accounted for using to mechanical efficiency, isentropic efficiency, and nozzle loss coefficient
- Radial swirl law for 3D blade generation
- Constant angular momentum
- Steady operation
  
## ⚡ Features
- **Inputs tab:** Structured entry of gas/inlet totals, power/efficiency targets, stage parameters, geometry controls, and aerofoil parameters (NACA used for simplicity and initial design)
- **Outputs tab:** Automatic table of key mean-line results (angles, loading, thermo states, choking flags, areas, blade heights, radii, geometry)
- **Visual tab:** Shaded 3D blade-row plot (stators and rotors) for rapid geometry checks
- **Side-by-side aerofoils:** Vane (stator) and rotor  plotted directly on the inputs page
- **Intended use:** To be used in conjunction with CFD to optimise a rocket turbine design for initial sizing

### 🧩 Inputs Tab
<img width="1721" height="1022" alt="inputs tab" src="https://github.com/user-attachments/assets/9c20b3b7-8842-4e54-aafb-e1d9d781780c" />


### 📊 Outputs Tab
<img width="1721" height="1021" alt="outputs tab" src="https://github.com/user-attachments/assets/eaee10e5-cdcc-4517-8d3d-8e555f13c7de" />


### 🌀 Visual Tab
<img width="1720" height="1021" alt="visual tab" src="https://github.com/user-attachments/assets/20c23b35-90db-45ff-85b8-51901fc81803" />

## 🏁 Rapid Installation
1. Download and put `RocketTATGbyAliAerospace.m` in MATLAB folder or your chosen folder
2. Open file then click run
3. Input your numbers and press **Run** to compute outputs and update plots.
Note: **Make sure to wait at least 20 seconds to 1 min for most computers before visual is shown.

### Aerofoils
- NACA 4-digit parameters for stator and rotor (`m`, `p`, `t`)
- This was implemented for ease of use


## 🧠 Notes
- Intended for **rapid design studies**
- The 3D model is a **visualisation** derived from mean-line and chosen aerofoil sections (not a CFD mesh generator)
- The first stator is at x = 0, then it cycles to rotor, stator, then rotor with increasing x


## 👤 Contact Me
Contact me if you have any questions or proposals.
