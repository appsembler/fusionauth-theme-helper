# make environmental variables available
. .env

# create theme directory
mkdir -p $TMP_DIR

# fetch raw theme data from FusionAuth
curl -s -H 'Authorization: '$API_KEY  $FUSIONAUTH_URL/api/theme/$THEME_ID > $TMP_DIR/themeout.json

# create template files from raw data
cat $TMP_DIR/themeout.json |jq '.theme.templates' > $TMP_DIR/templates.json
node splitfiles.js templates.json .ftl

# create default messages from raw data
cat $TMP_DIR/themeout.json |jq '.theme.defaultMessages'  |sed 's/^"//' |sed 's/"$//' |sed 's/\\"/"/g' |sed 's/\\\\/\\/g' |node convert-newlines.js > $TMP_DIR/defaultMessages.txt

# create localized messages from raw data
cat $TMP_DIR/themeout.json |jq '.theme.localizedMessages' > $TMP_DIR/localizedMessages.json
node splitfiles.js localizedMessages.json .txt

# create stylesheet from raw data
# empty string if null https://stackoverflow.com/questions/53135035/jq-returning-null-as-string-if-the-json-is-empty
cat $TMP_DIR/themeout.json |jq '.theme.stylesheet // empty'  |sed 's/^"//' |sed 's/"$//' |node convert-newlines.js > $TMP_DIR/styles.css

# clean up no longer needed files
rm $TMP_DIR/themeout.json $TMP_DIR/templates.json $TMP_DIR/localizedMessages.json
