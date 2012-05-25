express = require 'express'
scraper = require 'scraper'
jquery = require 'jQuery'

mongoose = require 'mongoose'

app = express.createServer express.logger(), express.static(__dirname + '/../public'), express.bodyParser(), express.cookieParser()

app.set 'view engine', 'coffee'
app.register '.coffee', require('coffeekup').adapters.express
app.set 'view options', layout: false

# Database
mongouser = process.env.MONGOUSER
mongopass = process.env.MONGOPASS
conn = mongoose.connect 'mongodb://'+mongouser+':'+mongopass+'@ds033067.mongolab.com:33067/friendcare'

Schema = mongoose.Schema
ObjectId = Schema.ObjectId
Update = new Schema
        date :
                type: Date,
                default: Date.now,
        sold : Number,
        available : Number

FSModel = conn.model('FSModel', Update)

isscraper = process.env.SCRAPER
if isscraper
        address = 'http://accupass.com/go/fst12spring'
        doscrape = (address) ->
                scraper address, (err, $) ->
                        msg = $ 'div.widget-container'
                        ours = $ msg[0]
                        list = ours.find 'li'
                        elem = $ list[2]
                        text = elem.text().trim().split('\n')
                        nums = text[1].trim()
                        match = nums.match(/(\d*)\D*(\d*)/m)
                        if match
                                sold = match[1]
                                total = match[2]
                                console.log sold, total
                                newdata = new FSModel sold: sold, available: total
                                newdata.save()
                                "OK"
                        else
                                "FAIL"
        setInterval ( -> doscrape address), 60000

# Main page
app.get '/', (req, res) ->
        res.send("hi!")


# Start server
port = process.env.PORT or 3000
app.listen port, -> console.log 'Listening on '+port
