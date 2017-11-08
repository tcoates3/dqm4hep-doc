# Quality Tests
A quality test (or 'qtest') is a piece of code that operates on data that the monitor has access to to verify it's "quality" or "goodness" against some statistical measure. Examples would be comparing the mean value of a histogram to an expected mean, or comparing a spectrum to a reference produced using Monte Carlo methods. These are an important part of the framework, allowing users and shifters to identify statistical properties or features in data that may not be obvious "by eye", improving their ability to identify any issues or anomalies with the data-taking or system under test.

DQM4HEP comes with an array of quality tests ready to use, though users can create their own if desired. The included quality tests are:
* Mean with expected range
* Mean below expected value
* Mean above expected value
* RMS with expected range
* RMS below expected value
* RMS above expected value
* Mean90 within expected range
* RMS90 within expected range

The following quality tests are planned but not yet implemented:
* Mean90 with expected range
* Mean90 below expected value
* Mean90 above expected value
* RMS90 with expected range
* RMS90 below expected value
* RMS90 above expected value
* Fit function and check parameters within range
* Fit function and compare χ^2^
* Likelihood fit
* Kolmogorov-Smirnov test
* Scalar distance between values

## Running a Quality Test
Quality tests can be run using the `dqm4hep-run-qtests` executable, found in `dqm4hep-core/bin/`. The required input for this executable is am XML steering file, and a root file containing the objects to run the quality tests on. An example of running is:

    dqm4hep-run-qtests -i steeringFile.xml -r rootFile.root

As with all DQM4HEP executables, running with the `--help` argument shows the possible arguments with their meanings and usage. The steering file controls which quality tests the executable runs. An example that runs all default quality tests can be found within `dqm4hep-core/tests/test_samples.xml`. This default file can also be run using the `ctest` command within the `dqm4hep-core/build/` directory, which performs a number of tests to check the compilation of DQM4HEP, which includes quality tests.

## Writing Quality Tests
Users can create their own quality tests if the included tests do not satisfy their requirements. The code for existing quality tests can be found within the `dqm4hep-core/source/src/qtest/` folder and can be used as references or templates.

### Quality Test Code
[...] The important functions are `canRun()` and `userRun()`:

The `canRun()` function tests whether certain criteria necessary to run the test are true. If these criteria are true, this test proceeds, otherwise this test is aborted and the quality test report will show that the test could not be run. By default these criteria are: the object to run on must exist and be accessible, and the object must not be empty. Some quality tests may have additional criteria specific to their application. User-created quality tests must use *at least* the default criteria. If a quality test could be run on data but the result would not be meaningful, then the `canRun()` function should be written to prevent this, if possible. For example, while a quality test for determining whether the mean is within a certain value *could* be run on a [thing], the result will not be meaningful. In this case, the quality test should attempt to check for this within the `canRun()` function, so that it can be aborted when the result would not be meaningful.

Here is an example of the `canRun()` function for the mean within expected range test:

```c++
bool MeanWithinExpectedTest::canRun(MonitorElement *pMonitorElement) const
{
    if(nullptr == pMonitorElement)
        return false;

    TH1 *pHistogram = pMonitorElement->objectTo<TH1>();

    if(nullptr == pHistogram)
        return false;

    // This cout is left here until I can test this out on an empty histogram
    std::cout << "Number of entries in histogram: " << typeToString(pHistogram->GetEntries())  << std::endl;
    if(pHistogram->GetEntries() < 1)
        return false;

    return true;
}
```

The `userRun()` function defines the process of the quality test itself. [...] Any messages to the user or logger -- such as reporting [...] -- should be output using `report.m_message` so that it appears in the quality report. Once the final "quality" or "goodness" statistic of the test is known, it should be output using `report.m_quality` so that it appears in the quality report. 

Here is an example of the `userRun()` function for the mean within expected range test:

```c++
StatusCode MeanWithinExpectedTest::userRun(MonitorElement *pMonitorElement, QualityTestReport &report)
{
    TH1 *pHistogram = pMonitorElement->objectTo<TH1>();
    const float mean(pHistogram->GetMean());
    const float range(fabs(m_meanDeviationUpper - m_meanDeviationLower));

    if(m_meanDeviationLower < mean && mean < m_meanDeviationUpper)
    {
        report.m_message = "Within expected range: expected " + typeToString(m_expectedMean) + ", got " + typeToString(mean);
    }
    else
    {
        report.m_message = "Out of expected range: expected " + typeToString(m_expectedMean) + ", got " + typeToString(mean);
    }

    const float chi = (mean - m_expectedMean)/range;
    const float probability = TMath::Prob(chi*chi, 1);
    report.m_quality = probability;
    report.m_isSuccessful = true;
    
    return STATUS_CODE_SUCCESS;
}
```

Additionally, the protected members of the quality test class, it's constructor, and the `readSettings()` function should all be modified to include the variables that are read in and instantiated from the XML steering file. Continuing with using the MeanWithinExpected test as an example, these would be the expected mean, the lower bound of the mean, and the upper bound of the mean (or `m_expectedMean`, `m_meanDeviationLower`, and `m_meanDeviationUpper` respectively).

### Quality Test Steering Files
[...] The steering file is an XML steering file that specifies the quality tests to execute, what histograms to execute them on and their parameters. The parameters of quality tests vary depending on the quality test but an example steering file that demonstrates the invocation of all default quality tests can be found at `dqm4hep-core/tests/test_samples.xml`, and is used for the `ctest` function that verifies that all quality tests are installed correctly following compilation of the dqm4hep-core package.

### Compiling Quality Tests
Once the code for a new quality is complete, it must be compiled. This can be done by navigaing to the `dqm4hep-core/build/` directory and repeating the installation commands:

    cmake ..
    make install

This adds the new quality tests to the cmake configuration and compiles the code. If the new quality tests were also implemented in the testing steering file (located in `dqm4hep-core/tests/test_samples.xml`) then the quality tests can then be tested by running the testing macro:

    ctest
    
The results of the quality tests will then be found within `dqm4hep-core/bin/Testing/Temporary/LastTest.log`.

[...]
