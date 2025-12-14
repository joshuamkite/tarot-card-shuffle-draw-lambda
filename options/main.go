package main

import (
	"embed"
	"fmt"
	"html/template"
	"log"
	"net/http"
	"time"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/awslabs/aws-lambda-go-api-proxy/httpadapter"
)

//go:embed templates/*
var content embed.FS

var (
	optionsLambda *httpadapter.HandlerAdapterV2
	tmpl          *template.Template
	initErr       error
)

func init() {
	log.Printf("Cold start for showOptionsPage")

	// Parse templates from the embedded filesystem with timing/logging
	start := time.Now()
	log.Printf("Parsing templates from embedded FS")
	var err error
	tmpl, err = template.ParseFS(content, "templates/*")
	if err != nil {
		initErr = fmt.Errorf("failed to parse templates: %v", err)
		log.Printf("Template parse error: %v", err)
	} else {
		log.Printf("Parsed templates in %s", time.Since(start))
	}

	// Create a new ServeMux instead of using default
	mux := http.NewServeMux()
	mux.HandleFunc("/", showOptionsPage)

	// Initialize the Lambda handler with the custom mux (timed)
	start = time.Now()
	optionsLambda = httpadapter.NewV2(mux)
	log.Printf("http adapter created in %s", time.Since(start))
	if initErr != nil {
		log.Printf("Initialization completed with errors: %v", initErr)
	} else {
		log.Printf("Initialization complete")
	}
}

func main() {
	lambda.Start(optionsHandler)
}

func optionsHandler(req events.APIGatewayV2HTTPRequest) (events.APIGatewayV2HTTPResponse, error) {
	log.Printf("Received request: %s %s", req.RequestContext.HTTP.Method, req.RawPath)

	if initErr != nil {
		log.Printf("Initialization error present, returning 500: %v", initErr)
		return events.APIGatewayV2HTTPResponse{
			StatusCode: http.StatusInternalServerError,
			Body:       initErr.Error(),
		}, nil
	}

	resp, err := optionsLambda.Proxy(req)
	if err != nil {
		log.Printf("Error processing request: %v", err)
		return events.APIGatewayV2HTTPResponse{
			StatusCode: http.StatusInternalServerError,
			Body:       err.Error(),
		}, nil
	}

	if resp.Headers == nil {
		resp.Headers = map[string]string{}
	}
	resp.Headers["Content-Type"] = "text/html"
	return events.APIGatewayV2HTTPResponse{
		StatusCode: resp.StatusCode,
		Headers:    resp.Headers,
		Body:       resp.Body,
	}, nil
}

func showOptionsPage(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "text/html")
	log.Printf("Handling request for %s", r.URL.Path)
	if tmpl == nil {
		msg := "templates not available"
		log.Printf("%s", msg)
		http.Error(w, msg, http.StatusInternalServerError)
		return
	}

	start := time.Now()
	err := tmpl.ExecuteTemplate(w, "options.html", nil)
	if err != nil {
		log.Printf("Error executing template: %v", err)
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	log.Printf("Rendered options.html in %s", time.Since(start))
}
