package main

import (
	"fmt"
	"net/http"

	"github.com/gin-gonic/gin"
)

type user struct {
	ID   string `json:"id"`
	Name string `json:"name"`
}

func UserList(c *gin.Context) {
	var users = []user{
		{ID: "1", Name: "AAAA"},
		{ID: "1", Name: "BBBB"},
	}
	c.JSON(http.StatusOK, users)
}

func HelloServer(w http.ResponseWriter, r *http.Request) {
	path := r.URL.Path[1:]
	if path != "" {
		fmt.Fprintf(w, "Hello, %s!", r.URL.Path[1:])
	} else {
		fmt.Fprint(w, "Hello World!")
	}
}

func Heartbeat(c *gin.Context) {
	fmt.Println("Hello World by Gin!")
	c.JSON(http.StatusOK, gin.H{
		"message": "Heartbeat from gin!",
	})
}

func AuthMiddleWare() gin.HandlerFunc {
	return func(c *gin.Context) {
		// here you can add your authentication method to authorize users.
		username := c.PostForm("user")
		password := c.PostForm("password")

		var json map[string]string
		c.BindJSON(&json)

		fmt.Printf("Username is %s, password is %s", username, password)
		if json["user"] == "foo" && json["password"] == "bar" {
			fmt.Println("200 prints here!")
			return
		} else {
			c.AbortWithStatus(http.StatusUnauthorized)
		}
	}
}

func AddV1User(c *gin.Context) {
	// AddUser

	c.JSON(http.StatusOK, "V1 User added")
}

func main() {
	r := gin.Default()
	r.GET("/ping", Heartbeat)

	// version 1
	apiV1 := r.Group("/api/v1")

	apiV1.GET("users", UserList)

	// User only can be added by authorized person
	authV1 := apiV1.Group("/", AuthMiddleWare())

	authV1.POST("users/add", AddV1User)

	// listen and serve on 0.0.0.0:8080 (for windows "localhost:8080")
	r.Run()
}
