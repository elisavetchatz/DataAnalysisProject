# DataAnalysisProject

# Analysis of Epileptic Discharge Duration Using TMS

## Project Overview
This project investigates the relationship between Transcranial Magnetic Stimulation (TMS) and the duration of epileptic discharges (ED). Using experimental data collected at the Laboratory of Transcranial Magnetic Stimulation at the Medical School of Aristotle University, multiple statistical and computational analyses were performed to explore the factors affecting ED duration.

## Objectives
1. **Probability Distribution Analysis**:
   - Identify the best-fit probability distributions for ED durations with and without TMS.
   - Visualize empirical and theoretical probability density functions (PDFs).

2. **Hypothesis Testing**:
   - Compare ED durations for different experimental setups and configurations (e.g., coil types).

3. **Confidence Intervals and Bootstrap**:
   - Assess the mean ED duration across different setups using confidence intervals or hypothesis testing.

4. **Correlation Analysis**:
   - Investigate the relationship between `preTMS` and `postTMS` durations for different setups.

5. **Regression Modeling**:
   - Fit multiple linear regression models to predict ED duration based on experimental parameters.
   - Evaluate and compare Full, Stepwise, and LASSO regression models.

6. **Model Validation**:
   - Split data into training and testing sets to evaluate model performance and prediction accuracy.

7. **Dimensionality Reduction**:
   - Explore Principal Component Regression (PCR) alongside traditional regression techniques.

8. 

## Dataset
The data is stored in `TMS.xlsx` and includes the following variables:
- `TMS`: Whether TMS was applied (1 = Yes, 0 = No).
- `EDduration`: Duration of ED in seconds.
- `preTMS` and `postTMS`: Durations before and after TMS application.
- `Setup`: Experimental setup codes (1 to 6).
- `Stimuli`, `Intensity`, `Frequency`, and `CoilCode`: Experimental parameters.
- `Spike`: Timing of TMS stimulus relative to the ED waveform.

## Key Results
- **Stepwise Regression**: Consistently outperformed Full and LASSO models in terms of Mean Squared Error (MSE) and Adjusted \(R^2\).
- **Spike Handling**: Models performed better when rows with missing `Spike` values were excluded.
- **Training vs. Testing**: Stepwise Regression showed better generalization compared to other models when evaluated on testing data.

## How to Run the Code
1. Place `TMS.xlsx` in the same directory as the MATLAB scripts.
2. Run the following scripts in order:
   - `Group40Exe1.m`: Probability distribution analysis.
   - `Group40Exe2.m`: Hypothesis testing for coil configurations.
   - `Group40Exe3.m`: Confidence interval analysis.
   - `Group40Exe4.m`: Correlation analysis between `preTMS` and `postTMS`.
   - `Group40Exe5.m`: Regression modeling for ED duration.
   - `Group40Exe6.m`: Model comparison (Full, Stepwise, LASSO).
   - `Group40Exe7.m`: Model validation with training and testing sets.
   - `Group40Exe8.m`: 

## Requirements
- **MATLAB** 
- **Statistics and Machine Learning Toolbox**

## Conclusion
This project highlights the potential of statistical modeling in understanding the impact of TMS on ED duration. The findings emphasize the importance of careful variable selection and robust model evaluation techniques.

## Authors
- Group 40
- December 2024

