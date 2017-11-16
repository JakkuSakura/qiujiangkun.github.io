root = global ? window

url ='https://qjk.s500.xrea.com/data/query.php'
#url = 'data/query.php'
root.post = (URL, PARAMS) =>
  console.log(PARAMS)
  temp = document.createElement("form")
  temp.action = URL
  temp.method = "post"
  temp.style.display = "none"
  for a,b of PARAMS
    opt = document.createElement("textarea")
    opt.name = a
    opt.innerHTML = b
#    alert(opt.name + opt.value)
    temp.appendChild(opt)
  document.body.appendChild(temp)
  temp.submit()
  return temp

root.sendScore = (username, score, fps, speed) =>
  query = """INSERT INTO bird (id, username, score, fps, speed, ip)\
 VALUE(NULL, '#{username}', '#{score}', '#{fps}', '#{speed}'\
, inet_aton('#{returnCitySN['cip']}'))"""
  $.ajax({
    url: url,
    data: {query : query}
    type: "POST",
    dataType: 'JSONP',
    success: (result) =>
      jsontree = result
      console.log jsontree
  })
#  root.post(url, {
#    query : query})
root.getHighScore = =>
  query = 'select * from bird order by score desc limit 10'
  $.ajax({
    url: url
    data: {query : query}
    type: "POST"
    dataType: 'JSONP'
    success: (res) =>
      console.log res
      show = "<table border=\"1\"><caption>排行榜</caption><tr><td>rusername</td><td>score</td><td>fps</td><td>speed</td><td>date</td></tr>"
#      lbl = ["id", "username", "score", "fps", "speed", "date", "ip"]
      for ele,j in res
        show += "<tr>"
        for el, i in ele
          show += "<td>" + el + "</td>" if 1 <= i <= 5
        show += '</tr>'
      show += "</table>"

      $( "#topscoretext" ).html(show)
  })
#  root.post(url, {
#    query : query})
#  username = prompt("请输入你的昵称:", "")
