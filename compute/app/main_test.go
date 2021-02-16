package main

import (
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestHelloServer(t *testing.T) {

	tests := []struct {
		name string
		path string
		code int
	}{
		{name: "Generic", path: "/world", code: 200},
		// TODO: Add test cases.
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			req, err := http.NewRequest("GET", tt.path, nil)
			if err != nil {
				t.Fatal(err)
			}
			rr := httptest.NewRecorder()
			handler := http.HandlerFunc(HelloServer)
			handler.ServeHTTP(rr, req)

			if status := rr.Code; status != tt.code {
				t.Errorf("handler returned wrong status code: got %v want %v",
					status, tt.code)
			}
		})
	}
}
