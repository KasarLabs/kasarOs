package main

import (
	"fmt"
	"os"

	"github.com/eiannone/keyboard"
)

type MenuItem struct {
	Text string
	Func func()
}

func main() {
	menu := []MenuItem{
		{"Install package A", func() { fmt.Println("Installing package A...") }},
		{"Install package B", func() { fmt.Println("Installing package B...") }},
		{"Quit", func() { os.Exit(0) }},
	}

	fmt.Println("Welcome to the installation menu!")
	fmt.Println("Please choose an option using the arrow keys:")
	for i, item := range menu {
		fmt.Printf("%s %s\n", getArrow(i == 0), item.Text)
	}

	var selectedIndex int
	err := keyboard.Open()
	if err != nil {
		panic(err)
	}
	defer func() {
		_ = keyboard.Close()
	}()

	for {
		char, key, err := keyboard.GetKey()
		if err != nil {
			panic(err)
		}

		if key == keyboard.KeyArrowUp {
			if selectedIndex > 0 {
				selectedIndex--
			}
		} else if key == keyboard.KeyArrowDown {
			if selectedIndex < len(menu)-1 {
				selectedIndex++
			}
		} else if key == keyboard.KeyEnter {
			menu[selectedIndex].Func()
		}

		fmt.Print("\033[H\033[2J") // clear screen
		fmt.Println("Please choose an option using the arrow keys:")
		for i, item := range menu {
			fmt.Printf("%s %s\n", getArrow(i == selectedIndex), item.Text)
		}

		if char == 'q' || key == keyboard.KeyCtrlC {
			break
		}
	}
}

func getArrow(selected bool) string {
	if selected {
		return ">"
	} else {
		return " "
	}
}
