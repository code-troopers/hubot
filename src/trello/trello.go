package main

import (
  "fmt"
  "os"
  "github.com/mrjones/oauth"
  "io/ioutil"
  "log"
  "net/url"
  "github.com/VojtechVitek/go-trello"
  "math/rand"
  "encoding/json"
  "time"
)

func getId(user string) string {
	switch user {
		case "@mattboll", "mattboll", "mbollot", "matthieubollot":
			return "50301bb2716f89e83c413cba"
		case "@cgatay", "cgatay", "samva", "gatayc":
			return "4ecdfd57548ea5000058bbe8"
		case "@rlucas", "rlucas", "lulu", "luluromain":
			return "50afa62db67b95ff4b011144"
		case "@bcousin", "bcousin", "benou":
			return "527fb052ab91203d1b0045b9"
		case "@jojo", "jojo", "jpotier", "jorispotier":
			return "4f68f582305b70cb3a0c01b5"
		case "@nanak", "nanak", "fchauveau":
			return "52b1813419070ca645021501"
		case "@vmaubert", "vmaubert":
			return "4eca13cbed87da0000826a6e"
	}
	return ""
}

func getRandom() string {
	r := rand.New(rand.NewSource(time.Now().UnixNano()))
	answers := []string{
		"50301bb2716f89e83c413cba",
		"4ecdfd57548ea5000058bbe8",
		"50afa62db67b95ff4b011144",
		"527fb052ab91203d1b0045b9",
		"4f68f582305b70cb3a0c01b5",
		"52b1813419070ca645021501",
		"4eca13cbed87da0000826a6e",
	}
	return answers[r.Intn(len(answers))]
}

func getMembers(users []string) string {
	avoidedId := []string{}
	for i:= 0; i< len(users) ; i++ {
		avoidedId = append(avoidedId, getId(users[i]))
	}
	member := ""
	c := 0
	for member == "" && c < 20 {
		c = c+1
		member = getRandom()
		for i:= 0; i< len(avoidedId) ; i++ {
			if member == avoidedId[i] {
				member = ""
			}
		}
	}

	return member
}

func main() {
	prurl := os.Args[1]
	member := ""
	if len(os.Args) > 2 {
		secondArg := os.Args[2]
		if secondArg == "not" && len(os.Args) > 3 {
			users := os.Args[3:len(os.Args)]
			member = getMembers(users)
		} else if secondArg != "none" {
			member = getId(secondArg)
		}
	} else {
		member = getMembers([]string{})
	}
	key := os.Getenv("TRELLO_KEY")
	token := os.Getenv("TRELLO_TOKEN")
	secret := os.Getenv("TRELLO_SECRET")
	atoken := os.Getenv("TRELLO_ATOKEN")
	// Pending MR
	destinationList := "56aa848e50254d1352546915"
	// ODJ
	// destinationList := "53bd72c30cc3a55aebb84f47"
	// unused list for test
	// destinationList := "52fa3f86dff7a088312f5c18"

	newCard := trello.Card{Name: prurl,
		Desc: prurl,
		Pos: 0,
		IdList: destinationList,
		IdMembers: []string{member},
		}


	c := oauth.NewConsumer(
		key,
		token,
		oauth.ServiceProvider{
			RequestTokenUrl:   "https://trello.com/1/OAuthGetRequestToken",
			AuthorizeTokenUrl: "https://trello.com/1/OAuthAuthorizeToken",
			AccessTokenUrl:    "https://trello.com/1/OAuthGetAccessToken",
		},
	)


	// App Name
	c.AdditionalAuthorizationUrlParams["name"] = "Trello hubot"
	// Token Expiration - Default 30 days
	c.AdditionalAuthorizationUrlParams["expiration"] = "never"
	// Authorization Scope
	c.AdditionalAuthorizationUrlParams["scope"] = "read,write"

	c.Debug(false)

//	if the app is not authorized, we should get an authorized token
//	requestToken, u, err := c.GetRequestTokenAndUrl("")
//	if err != nil {
//		log.Fatal(err)
//	}
//
//	fmt.Println("(1) Go to: " + u)
//	fmt.Println("(2) Grant access, you should get back a verification code.")
//	fmt.Println("(3) Enter that verification code here: ")

//	accessToken, err := c.AuthorizeToken(requestToken, verificationCode)
//	if err != nil {
//		log.Fatal(err)
//	}

	accessToken := &oauth.AccessToken{Token:atoken,Secret:secret}

	client, err := c.MakeHttpClient(accessToken)
	if err != nil {
		log.Fatal("Making http client err")
		log.Fatal(err)
	}

//	response, err := client.Get("https://trello.com/1/members/me")

	response, err := client.PostForm("https://trello.com/1/cards/", url.Values{"name": []string{newCard.Name},
                "desc": []string{prurl},
                "pos": []string{"top"},
                "idList": []string{destinationList},
                "idMembers": []string{member},
                })
	if err != nil {
		log.Fatal("postform err")
		log.Fatal(err)
	}
	defer response.Body.Close()

	bits, err := ioutil.ReadAll(response.Body)
	if err != nil {
		log.Fatal("Reading body err")
		log.Fatal(err)
	}
	var cardResult trello.Card
	err = json.Unmarshal(bits, &cardResult)
	if err != nil {
		fmt.Println(err)
	}
	fmt.Println(cardResult.Url)

}
