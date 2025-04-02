/*
Copyright © 2023 Vinzenz Stadtmueller vinzenz.stadtmueller@fh-hagenberg.at
*/
package cmd

import (
	"fmt"
	"os"

	"github.com/spf13/cobra"
	"github.com/spf13/viper"
)

var cfgFile string

// rootCmd represents the base command when called without any subcommands
var rootCmd = &cobra.Command{
	Use:   "recipe",
	Short: "A brief description of your application",
	Long: `A longer description that spans multiple lines and likely contains
examples and usage of your application. For example:

Cobra is a CLI library for Go that empowers applications.
This application is a tool to generate the needed files
to quickly create a Cobra application.`,
}

// Execute adds all child commands to the root command and sets flags appropriately.
// This is called by main.main(). It only needs to happen once to the rootCmd.
func Execute() {
	err := rootCmd.Execute()
	if err != nil {
		os.Exit(1)
	}
}

func init() {
	cobra.OnInitialize(initConfig)

	// Define config file flag
	rootCmd.PersistentFlags().StringVar(&cfgFile, "config", "", "config file (default is $HOME/.recipe.yaml)")

	// Example toggle flag
	rootCmd.Flags().BoolP("toggle", "t", false, "Help message for toggle")
}

// initConfig reads in config file and ENV variables if set.
func initConfig() {
	if cfgFile != "" {
		// Use config file from the flag.
		viper.SetConfigFile(cfgFile)
	} else {
		// Find home directory.
		home, err := os.UserHomeDir()
		cobra.CheckErr(err)

		// Search config in home directory with name ".recipe" (without extension).
		viper.AddConfigPath(home)
		viper.SetConfigType("yaml")
		viper.SetConfigName(".recipe")
	}

	viper.AutomaticEnv() // read in environment variables that match

	// Set default values
	viper.SetDefault("db_host", "localhost")
	viper.SetDefault("db_port", "5432")
	viper.SetDefault("db_name", "postgres")
	viper.SetDefault("db_user", "postgres")
	viper.SetDefault("db_password", "postgres")

	// Bind environment variables with error checking
	mustBind := func(key, env string) {
		if err := viper.BindEnv(key, env); err != nil {
			fmt.Fprintf(os.Stderr, "Error binding env var %s: %v\n", env, err)
			os.Exit(1)
		}
	}

	mustBind("db_host", "db_host")
	mustBind("db_port", "db_port")
	mustBind("db_user", "db_user")
	mustBind("db_password", "db_password")
	mustBind("db_name", "db_name")

	// Read config file (optional)
	if err := viper.ReadInConfig(); err == nil {
		fmt.Fprintln(os.Stderr, "Using config file:", viper.ConfigFileUsed())
	}
}
