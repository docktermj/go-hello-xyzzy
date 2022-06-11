package main

import (
    "fmt"
    "encoding/json"
    "context"

    xyzzy "github.com/docktermj/xyzzygoapi/g2diagnostic"
)

// Values updated via "go install -ldflags" parameters.

var programName string = "unknown"
var buildVersion string = "0.0.0"
var buildIteration string = "0"

/*
 * Internal methods.
 */

type XyzzyConfigurationPipeline struct {
    ConfigPath   string `json:"CONFIGPATH"`
    ResourcePath string `json:"RESOURCEPATH"`
    SupportPath  string `json:"SUPPORTPATH"`
}

type XyzzyConfigurationSql struct {
    Connection string `json:"CONNECTION"`
}

type XyzzyConfiguration struct {
    Pipeline XyzzyConfigurationPipeline `json:"PIPELINE"`
    Sql      XyzzyConfigurationSql      `json:"SQL"`
}

func getConfigurationJson() string {
    resultStruct := XyzzyConfiguration{
        Pipeline: XyzzyConfigurationPipeline{
            ConfigPath:   "/etc/opt/senzing",
            ResourcePath: "/opt/senzing/g2/resources",
            SupportPath:  "/opt/senzing/data",
        },
        Sql: XyzzyConfigurationSql{
            Connection: "postgresql://postgres:postgres@127.0.0.1:5432:G2/",
        },
    }

    resultBytes, _ := json.Marshal(resultStruct)
    return string(resultBytes)
}

func getG2diagnostic() (xyzzy.G2diagnostic, error) {
    var err error = nil
    g2diagnostic := xyzzy.G2diagnosticImpl{}
    ctx := context.TODO()

    moduleName := "Test module name"
    verboseLogging := 0 // 0 for no Senzing logging; 1 for logging
    iniParams := getConfigurationJson()

    err = g2diagnostic.Init(ctx, moduleName, iniParams, verboseLogging)
    return &g2diagnostic, err
}

func main() {
    g2diagnostic, _ := getG2diagnostic()
    ctx := context.TODO()
    secondsToRun := 1
    actual, err := g2diagnostic.CheckDBPerf(ctx, secondsToRun)
    if err != nil {
        fmt.Println(err)
    }
    fmt.Println(actual)
}
