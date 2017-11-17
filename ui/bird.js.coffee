bird_width = 43
bird_height = 15
bird_left_x = 99
bird_center_x = bird_left_x + bird_width/2

pipes_width = 69
pipes_height = 128

state_ground = 418
jQuery.fn.shake = (intShakes, intDistance, intDuration) ->
  @each ->
    $(this).css "position", "relative"
    x = 1

    while x <= intShakes
      $(this).animate(
        left: (intDistance * -1)
      , ((intDuration / intShakes) / 4)).animate(
        left: intDistance
      , ((intDuration / intShakes) / 2)).animate
        left: 0
      , ((intDuration / intShakes) / 4)
      x++
    return
  this

class Runner
  constructor: ->
    @FPS = 60 # frame / s
    @BOOST_UP = 1.0
    @set_speed()
    @roles = []
  set_speed: ->
    @FRAME_TIME = 1000 / @BOOST_UP / @FPS # ms / fps
    @GROUND_SPEED_PER_SEC = 190
    @GROUND_SPEED = @GROUND_SPEED_PER_SEC / @FPS # px/frame_time
    @GRAVITY_PER_SEC = 35
    @GRAVITY = @GRAVITY_PER_SEC / (@FPS * @FPS / 60) # px/frame_time^2
    @BIRD_JUMP_SPEED_PER_SEC = 510
    @BIRD_JUMP_SPEED = @BIRD_JUMP_SPEED_PER_SEC / @FPS # px/frame_time
  add: (role)->
    @roles.push role
    role.runner = @

  run: ->
    start_time = new Date().getTime()
    setInterval =>
      new_time = new Date().getTime()
      deltat = new_time - start_time
      if deltat > @FRAME_TIME
        for role in @roles
          role.draw()
        start_time = new_time
    , 1
window.AI_ON = 0
class AI
  constructor: ->
    @pipes = window.game.pipes.pipes
    @bird = window.game.bird
    console.log "AI Enabled" if window.AI_ON
    window.game.runner.add @
  draw: ->
    return unless window.AI_ON
    if @bird.is_dead
      return
    if @pipes.length > 0
      p = @pipes[0]
      i = 0
      if bird_left_x > p.data('left') + pipes_width && @pipes.length > 1
        p = @pipes[1]
        i = 1
      t = Math.floor(p.data('left') - (@bird.left + bird_width) + 0.5)
      if t >= 0
        if @bird.speed > 0
          fnly = @bird.top + bird_height
          spd = @bird.speed
          g = @bird.gravity
          for i in [1..t]
            fnly -= spd
            spd += g
        else
          fnly = @bird.top + bird_height - @bird.speed
      else
        fnly = @bird.top + bird_height - @bird.speed
#      console.log "fnly #{fnly}"
      if fnly >= p.data('y1')
        @bird.jump()



class Stage
  constructor: ->
    @$elm = jQuery('<div></div>')
      .addClass('stage')
      .appendTo(document.body)

    @$ground = jQuery('<div></div>')
      .addClass('ground')
      .appendTo(@$elm)

    @bgleft = 0

    @move()

  build_elm: (name)->
    jQuery('<div></div>')
      .addClass(name)
      .appendTo(@$elm)

  move: ->
    @$elm.removeClass('stop')

  stop: ->
    @$elm.addClass('stop')

  draw: ->
    return if @$elm.hasClass('stop')
    @bgleft -= @runner.GROUND_SPEED
    @$ground.css
      'background-position': "#{@bgleft}px 0"

class Bird
  constructor: ->
    @$elm = jQuery('<div></div>')
      .addClass('bird')

    @speed = 0
    @is_dead = false
    @gravity = 0

  draw: ->
    @_repos()
    @hit()

  _repos: ->
    if @gravity != 0
      if @speed > 0
        @$elm.addClass('up').removeClass('down')
      else
        @$elm.addClass('down').removeClass('up')

      new_top = @top - @speed # 这里的speed是每帧的位移

      if new_top >= state_ground
        @pos(@left, state_ground)
        @speed = 0
        @gravity = 0
      else
        @pos(@left, new_top)
        @speed = @speed - @gravity

  pos: (left, top)->
    @left = left
    @top = top

    @top = 0 if @top < 0

    @$elm.css
      left: @left
      top: @top

  hit: ->
    # 撞地板，撞管子的判断
    return if @is_dead

    # 撞地板
    if @top >= state_ground
      @state_dead()
      return

    # 撞管子
    # bird center x = 120.5
    # pipe center x = left + pipes_width / 2 = 34.5
    W =  (bird_width + pipes_width) / 2
    pipes = window.game.pipes.pipes
    if pipes.length > 0
      p = pipes[0]

      bird_mx = bird_center_x
      pipe_mx = p.data('left') + pipes_width / 2

      if Math.abs(bird_mx - pipe_mx) <= W
        if @top < p.data('y0') || @top + bird_height > p.data('y1')
          @state_dead()
          console.log "Hit the pipe y1:#{p.data('y1')} y0:#{p.data('y0')} bt #{@top} bb #{@top - bird_height}"
  state_suspend: ->
    # 悬浮
    @$elm.removeClass('no-suspend').removeClass('down').removeClass('up')

    @speed = 0
    @is_dead = false
    @$elm.removeClass('dead')
    @gravity = 0

  state_fly: ->
    # 飞行
    @$elm.addClass('no-suspend')
    @jump()

  state_dead: ->
    # 死亡
    @is_dead = true
    @$elm.addClass('dead')

    jQuery(document).trigger 'bird:dead'


  jump: ->
    return if @is_dead

    @gravity = @runner.GRAVITY
    @speed = @runner.BIRD_JUMP_SPEED

class Score
  constructor: ->
    @$elm = jQuery('<div></div>')
      .addClass('score')

  set: (score)->
    @score = score

    @$elm.html('')

    for num in (score + '').split('')
      $n = jQuery('<div></div>')
        .addClass('number')
        .addClass("n#{num}")
      @$elm.append $n

    setTimeout =>
      @$elm.css
        'margin-left': - @$elm.width() / 2
    , 1

  inc: ->
    @set(@score + 1)
    console.log "Passed"

class ScoreBoard
  constructor: ->
    @$elm = jQuery('<div></div>')
      .addClass('score_board')

    @$score = jQuery('<div></div>')
      .addClass('score')
      .appendTo @$elm
      .css
        left: 'auto'
        top: 45
        right: 30

    @$max_score = jQuery('<div></div>')
      .addClass('score')
      .appendTo @$elm
      .css
        left: 'auto'
        top: 102
        right: 30

    @$new_record = jQuery('<div></div>')
      .addClass('new_record')
      .appendTo @$elm

  set: (score)->
    sb = switch
      when score < 15 then 'score_board_N.png'
      when score < 25 then 'score_board_C.png'
      when score < 40 then 'score_board_S.png'
      else 'score_board_G.png'
    @$elm.css({"background-image" : "url(ui/images/#{sb})"})

    localStorage.max_score = 0 if !localStorage.max_score

    if localStorage.max_score < score
      localStorage.max_score = score
      @$new_record.show()
    else
      @$new_record.hide()

    @$score.html('')
    @$max_score.html('')

    for num in (score + '').split('')
      $n = jQuery('<div></div>')
        .addClass('number')
        .addClass("n#{num}")
      @$score.append $n

    for num in (localStorage.max_score + '').split('')
      $n = jQuery('<div></div>')
        .addClass('number')
        .addClass("n#{num}")
      @$max_score.append $n
    unless window.AI_ON
      window.nknm = prompt "请输入你的昵称:", "Player" unless window.nknm
      window.sendScore(window.nknm, score, window.game.runner.FPS, window.game.runner.BOOST_UP)
      setInterval "window.getHighScore()",1000

class Pipes
  constructor: ->
    @xgap = 140 + pipes_width # 左右管子间距，140 还要加上管子宽度 69

    @ygap = pipes_height # 上下管子间距

    @pipes = []
    @is_stop = true

  generate: ->
    # 生成一对新水管
    # 开口位置 y0 y1 随机在 70 到 448 - 128 - 70 = 250 之间

    y0 = ~~(Math.random() * (250 - 70 + 1) + 70)
    y1 = y0 + @ygap

    last_pipe = @pipes[@pipes.length - 1]
    if last_pipe
      left = last_pipe.data('left') + @xgap
    else
      left = 384 * 2 # 1个屏幕以外

    $pipe = jQuery('<div></div>')
      .addClass 'pipe'
      .css 'left', left
      .data 'left', left
      .data 'y0', y0
      .data 'y1', y1

    
#    $top =
    jQuery('<div></div>')
    .addClass 'top'
    .appendTo $pipe
    .css
      height: y0

#    $bottom =
     jQuery('<div></div>')
     .addClass 'bottom'
     .appendTo $pipe
     .css
       top:y1

    @pipes.push $pipe

    jQuery(document).trigger 'pipe:created', $pipe

  draw: ->
    return if @is_stop

    for $pipe in @pipes
      left = $pipe.data('left') - @runner.GROUND_SPEED
      $pipe
        .css 'left', left
        .data 'left', left

    if @pipes.length > 0
      if @pipes.length < 3
        @generate()

      pipe0 = @pipes[0]

      # 1个屏幕以外
      if pipe0.data('left') < -pipes_width
        pipe0.remove()
        @pipes.splice(0, 1)

      # 判断是否加分
      pipe_center = pipes_width / 2
      pass_line_x = bird_left_x + bird_width / 2 - pipe_center
      if pipe0.data('left') < pass_line_x
        if !pipe0.data('passed')
          pipe0.data('passed', true)
          jQuery(document).trigger('score:add')

  stop: ->
    @is_stop = true

  clear: ->
    for p in @pipes
      p.remove()
    @pipes = []

  start: ->
    @is_stop = false
    @generate()

class Game
  constructor: (@stage)->
    @stage = new Stage
    @bird  = new Bird
    @score = new Score
    @score_board = new ScoreBoard
    @pipes = new Pipes

    @runner = new Runner
    @runner.add @bird
    @runner.add @pipes
    @runner.add @stage
    @runner.run()



    @_init_objects()
    @_init_events()

  _init_objects: ->
    @$logo      = @stage.build_elm 'logo'
    @$start     = @stage.build_elm 'start'
    @$ok        = @stage.build_elm 'ok'
    @$get_ready = @stage.build_elm 'get_ready'
    @$tap       = @stage.build_elm 'tap'
    @$game_over = @stage.build_elm 'game_over'

    @$score_board = @score_board.$elm
      .appendTo(@stage.$elm)

    @$bird = @bird.$elm
      .appendTo(@stage.$elm)

    @$score = @score.$elm
      .appendTo(@stage.$elm)

    @objects = {
      'logo': @$logo
      'start': @$start
      'ok': @$ok
      'get_ready': @$get_ready
      'game_over': @$game_over
      'tap': @$tap
      'score': @$score
      'score_board': @$score_board

      'bird': @$bird
    }
  _fly: ->
    if @state == 'ready'
      @fly()
      return
    if @state == 'fly'
      @bird.jump()

  _init_events: ->
    @$start.on 'click', =>
      @stage.$elm.fadeOut 200, =>
        @ready()
        @stage.$elm.fadeIn 200

    @$ok.on 'click', =>
      @stage.$elm.fadeOut 200, =>
        @begin()
        @stage.$elm.fadeIn 200


    @stage.$elm.on 'mousedown', =>
        @_fly()

    jQuery(document).on 'bird:dead', =>
      @over()

    jQuery(document).on 'bird:hit', =>
      @bird.state_dead()

    jQuery(document).on 'pipe:created', (evt, $pipe)=>
      @stage.$elm.append($pipe)

    jQuery(document).on 'score:add', =>
      @score.inc()
      @runner.FRAME_TIME *= 0.80 if @score.score % 20 == 0


  _show: ->
    for k, v of @objects
      v.hide()

    for name in arguments
      o = @objects[name]
      o.show() if o

  begin: ->
    @state = 'begin'
    @_show('logo', 'bird', 'start')
    @bird.pos(310, 145)#logo
    @stage.move()
    @bird.state_suspend()
    @runner.set_speed()
    @pipes.clear()

  ready: ->
    @state = 'ready'

    @_show('bird', 'tap', 'score')
    @$get_ready.fadeIn 400

    @bird.pos(bird_left_x, 237)
    @bird.state_suspend()
    @score.set(0)

  fly: ->
    @state = 'fly'

    @_show('get_ready', 'bird', 'tap', 'score')
    @$get_ready.fadeOut 400
    @$tap.fadeOut 400

    @bird.state_fly()
    @pipes.start()
    @ai = new AI


  over: ->
    @state = 'over'
    @_show('bird', 'score')

    @stage.stop()
    @pipes.stop()

    @stage.$elm.shake(6, 3, 100)
    setTimeout =>
      @$score.fadeOut()
      @$game_over.fadeIn =>
        @score_board.set(@score.score)
        @$score_board.show()
          .css
            top: 512
          .delay(300)
          .animate
            top: 179
          , =>
            @$ok.fadeIn()
    , 500

jQuery ->
  window.game = new Game
  window.game.begin()

