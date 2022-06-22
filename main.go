package main

import (
	"context"
	"fmt"
	"log"
	"math/rand"
	"strconv"
	"time"

	"github.com/docktermj/g2-sdk-go/g2diagnostic"
	"github.com/docktermj/g2-sdk-go/g2engine"
	"github.com/docktermj/go-xyzzy-helpers/g2configuration"
	"github.com/docktermj/go-xyzzy-helpers/logger"
)

// Values updated via "go install -ldflags" parameters.

var programName string = "unknown"
var buildVersion string = "0.0.0"
var buildIteration string = "0"

// ----------------------------------------------------------------------------
// Constants
// ----------------------------------------------------------------------------

const MessageIdFormat = "senzing-9999%04d"

// ----------------------------------------------------------------------------
// Internal methods - names begin with lower case
// ----------------------------------------------------------------------------

func getG2diagnostic(ctx context.Context) (g2diagnostic.G2diagnostic, error) {
	var err error = nil
	g2diagnostic := g2diagnostic.G2diagnosticImpl{}

	moduleName := "Test module name"
	verboseLogging := 0 // 0 for no Senzing logging; 1 for logging
	iniParams, jsonErr := g2configuration.BuildSimpleSystemConfigurationJson("")
	if jsonErr != nil {
		return &g2diagnostic, jsonErr
	}

	err = g2diagnostic.Init(ctx, moduleName, iniParams, verboseLogging)
	return &g2diagnostic, err
}

func getG2engine(ctx context.Context) (g2engine.G2engine, error) {
	var err error = nil
	g2engine := g2engine.G2engineImpl{}

	moduleName := "Test module name"
	verboseLogging := 0 // 0 for no Senzing logging; 1 for logging
	iniParams, jsonErr := g2configuration.BuildSimpleSystemConfigurationJson("")
	if jsonErr != nil {
		return &g2engine, jsonErr
	}

	err = g2engine.Init(ctx, moduleName, iniParams, verboseLogging)
	return &g2engine, err
}

// ----------------------------------------------------------------------------
// Main
// ----------------------------------------------------------------------------

func main() {
	ctx := context.TODO()

	// Randomize random number generator.

	rand.Seed(time.Now().UnixNano())

	// Configure the "log" standard library.

	log.SetFlags(log.Llongfile | log.Ldate | log.Lmicroseconds | log.LUTC)
	logger.SetLevel(logger.LevelInfo)

	// Create a G2diagnostic object.

	g2diagnostic, g2diagnosticErr := getG2diagnostic(ctx)
	if g2diagnosticErr != nil {
		logger.LogMessageFromError(MessageIdFormat, 1, "Running getG2diagnostic(ctx)", g2diagnosticErr)
	}

	// Call g2diagnostic.CheckDBPerf

	secondsToRun := 1
	actual, err := g2diagnostic.CheckDBPerf(ctx, secondsToRun)
	if err != nil {
		logger.Info(err)
		logger.LogMessageFromError(MessageIdFormat, 1, "Running g2diagnostic.CheckDBPerf(ctx, secondsToRun)", g2diagnosticErr, strconv.Itoa(secondsToRun))

	}
	fmt.Println(actual)

	// Create a G2engine object.

	g2engine, g2engineErr := getG2engine(ctx)
	if g2engineErr != nil {
		logger.LogMessageFromError(MessageIdFormat, 1, "Running getG2engine(ctx)", g2engineErr)
	}

	// Call g2engine.AddRecordWithInfo

	dataSourceCode := "TEST"
	recordID := strconv.Itoa(rand.Intn(1000000000))
	jsonData := fmt.Sprintf(
		"%s%s%s",
		`{"SOCIAL_HANDLE": "flavorh", "DATE_OF_BIRTH": "4/8/1983", "ADDR_STATE": "LA", "ADDR_POSTAL_CODE": "71232", "SSN_NUMBER": "053-39-3251", "ENTITY_TYPE": "TEST", "GENDER": "F", "srccode": "MDMPER", "CC_ACCOUNT_NUMBER": "5534202208773608", "RECORD_ID": "`,
		recordID,
		`", "DSRC_ACTION": "A", "ADDR_CITY": "Delhi", "DRIVERS_LICENSE_STATE": "DE", "PHONE_NUMBER": "225-671-0796", "NAME_LAST": "SEAMAN", "entityid": "284430058", "ADDR_LINE1": "772 Armstrong RD"}`)
	loadID := dataSourceCode
	var flags int64 = 0

	withInfo, withInfoErr := g2engine.AddRecordWithInfo(ctx, dataSourceCode, recordID, jsonData, loadID, flags)
	if withInfoErr != nil {
		logger.LogMessageFromError(MessageIdFormat, 1, "Running g2engine.AddRecordWithInfo(ctx, dataSourceCode, recordID, jsonData, loadID, flags)", withInfoErr, dataSourceCode, recordID, jsonData, loadID, strconv.FormatInt(flags, 2))
	}

	fmt.Printf("WithInfo: %s\n)", withInfo)
}
