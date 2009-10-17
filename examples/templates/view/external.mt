<html>
  <head>
    <title>Template::Mustache external</title>
  </head>
  <body>
  <h1>{{header}}</h1>
    {{{link_home}}}
    <p>
      Here you can pass some stuff if you like, parameters are just passed like this:<br />
      {{{link_one}}}<br />
      {{{link_two}}}<br />
      {{{link_three}}}
    </p>
    <div>
      The arguments you have passed to this action are:
      {{#args_empty}}
        none
      {{/args_empty}}
      {{#not_empty}}
        {{#args}}
          <span>{{arg}}</span>
        {{/args}}
      {{/not_empty}}
    </div>
    <div>
      {{params}}
    </div>
  </body>
</html>
