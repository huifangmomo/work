
var wrapper = document.createElement('div')
wrapper.id = 'wrapper'
var icon = document.createElement('img')
icon.id = 'icon'
icon.setAttribute('src', 'http://118.31.66.90/wallet/frontend/web/imgs/menu/btn_suspension_1.png')
wrapper.appendChild(icon)
var list = document.createElement('ul')
list.id = 'list'
var exit = document.createElement('li')
exit.id = 'exit'
list.appendChild(exit)
wrapper.appendChild(list)
var first=document.body.firstChild
document.body.insertBefore(wrapper,first)

// css
wrapper.style.cssText += ';position: fixed;width: 50px;height: 50px;z-index: 9999;'
icon.style.cssText += ';width: 50px;height: 50px;position: absolute;left: 0;top: 0;z-index: 1;border-radius: 50%'
list.style.display = 'none';
list.style.cssText += ';width: 122px;height: 35px;background: rgb(255, 255, 255);border-radius: 5px;box-shadow: rgba(0, 0, 0, 0.1) 0px 2px 2px 1px;list-style: none;position: absolute;left: 25px;top: 25px;padding: 0;margin: 0;'
exit.style.cssText += ';width: 100px;height: 35px;background-repeat: no-repeat;background-size: contain;background-position: center;margin: auto;'
exit.style.backgroundImage = 'url(http://118.31.66.90/wallet/frontend/web/imgs/menu/exit_1.png)';

var clientWidth = window.innerWidth
var clientHeight = window.innerHeight
// layer
icon.style.opacity = '0.7'
layer()
function layer() {
    wrapper.addEventListener('click', function(e) {
                             icon.style.opacity = '1'
                             if( (clientWidth - e.pageX) > 125 && (clientHeight - e.pageY) > -130 ) {
                             if(list.style.display === 'block') {
                             list.style.display = 'none';
                             icon.setAttribute('src', 'http://118.31.66.90/wallet/frontend/web/imgs/menu/btn_suspension_1.png');
                             setTimeout(function(){
                                        icon.style.opacity = '0.7'
                                        }, 2000)
                             } else {
                             list.style.display = 'block';
                             icon.setAttribute('src', 'http://118.31.66.90/wallet/frontend/web/imgs/menu/btn_suspension_2.png');
                             icon.style.opacity = '1'
                             }
                             e.stopPropagation()
                             }
                             });
    document.addEventListener('click', function(e) {
                              icon.style.opacity = '1'
                              if(list.style.display === 'block') {
                              list.style.display = 'none';
                              icon.setAttribute('src', 'http://118.31.66.90/wallet/frontend/web/imgs/menu/btn_suspension_1.png');
                              setTimeout(function(){
                                         icon.style.opacity = '0.7'
                                         }, 2000)
                              } else {
                              icon.style.opacity = '1'
                              }
                              });
    list.addEventListener('click', function(e) {
                          e.stopPropagation()
                          });
    exit.addEventListener('click', function(e) {
                          window.location.href = 'http://118.31.66.90/games/'
                          });
    exit.addEventListener('touchstart', function(e) {
                          exit.style.backgroundImage = 'url(http://118.31.66.90/wallet/frontend/web/imgs/menu/exit_2.png)';
                          });
    exit.addEventListener('touchend', function(e) {
                          exit.style.backgroundImage = 'url(http://118.31.66.90/wallet/frontend/web/imgs/menu/exit_1.png)';
                          });
}

wrapper.addEventListener('touchmove', function() {
                         if(list.style.display === 'none') {
                         setTimeout(function(){
                                    icon.style.opacity = '0.7'
                                    }, 5000)
                         }
                         })


// Inertia
var Inertia = function (ele, options) {
    var defaults = {
        // 是否吸附边缘
    edge: true
    };
    
    var params = {};
    options = options || {};
    for (var key in defaults) {
        if (typeof options[key] !== 'undefined') {
            params[key] = options[key];
        } else {
            params[key] = defaults[key];
        }
    }
    
    var data = {
    distanceX: 0,
    distanceY: 0
    };
    
    var win = window;
    
    // 浏览器窗体尺寸
    var winWidth = win.innerWidth;
    var winHeight = win.innerHeight;
    
    if (!ele) {
        return;
    }
    
    // 设置transform坐标等方法
    var fnTranslate = function (x, y) {
        x = Math.round(1000 * x) / 1000;
        y = Math.round(1000 * y) / 1000;
        
        ele.style.webkitTransform = 'translate(' + [x + 'px', y + 'px'].join(',') + ')';
        ele.style.transform = 'translate3d(' + [x + 'px', y + 'px', 0].join(',') + ')';
    };
    
    var strStoreDistance = '';
    // 居然有android机子不支持localStorage
    if (ele.id && win.localStorage && (strStoreDistance = localStorage['Inertia_' + ele.id])) {
        var arrStoreDistance = strStoreDistance.split(',');
        ele.distanceX = +arrStoreDistance[0];
        ele.distanceY = +arrStoreDistance[1];
        fnTranslate(ele.distanceX, ele.distanceY);
    }
    
    // 显示拖拽元素
    ele.style.visibility = 'visible';
    
    // 如果元素在屏幕之外，位置使用初始值
    var initBound = ele.getBoundingClientRect();
    
    if (initBound.left < -0.5 * initBound.width ||
        initBound.top < -0.5 * initBound.height ||
        initBound.right > winWidth + 0.5 * initBound.width ||
        initBound.bottom > winHeight + 0.5 * initBound.height
        ) {
        ele.distanceX = 0;
        ele.distanceY = 0;
        fnTranslate(0, 0);
    }
    
    ele.addEventListener('touchstart', function (event) {
                         // if (data.inertiaing) {
                         //   return;
                         // }
                         
                         icon.style.opacity = '1'
                         
                         var events = event.touches[0] || event;
                         
                         data.posX = events.pageX;
                         data.posY = events.pageY;
                         
                         data.touching = true;
                         
                         if (ele.distanceX) {
                         data.distanceX = ele.distanceX;
                         }
                         if (ele.distanceY) {
                         data.distanceY = ele.distanceY;
                         }
                         
                         // 元素的位置数据
                         data.bound = ele.getBoundingClientRect();
                         
                         data.timerready = true;
                         });
    
    // easeOutBounce算法
    /*
     * t: current time（当前时间）；
     * b: beginning value（初始值）；
     * c: change in value（变化量）；
     * d: duration（持续时间）。
     **/
    var easeOutBounce = function (t, b, c, d) {
        if ((t /= d) < (1 / 2.75)) {
            return c * (7.5625 * t * t) + b;
        } else if (t < (2 / 2.75)) {
            return c * (7.5625 * (t -= (1.5 / 2.75)) * t + 0.75) + b;
        } else if (t < (2.5 / 2.75)) {
            return c * (7.5625 * (t -= (2.25 / 2.75)) * t + 0.9375) + b;
        } else {
            return c * (7.5625 * (t -= (2.625 / 2.75)) * t + 0.984375) + b;
        }
    };
    
    document.addEventListener('touchmove', function (event) {
                              
                              if (data.touching !== true) {
                              return;
                              }
                              
                              // 当移动开始的时候开始记录时间
                              if (data.timerready == true) {
                              data.timerstart = +new Date();
                              data.timerready = false;
                              }
                              
                              event.preventDefault();
                              
                              var events = event.touches[0] || event;
                              
                              data.nowX = events.pageX;
                              data.nowY = events.pageY;
                              
                              var distanceX = data.nowX - data.posX,
                              distanceY = data.nowY - data.posY;
                              
                              // 此时元素的位置
                              var absLeft = data.bound.left + distanceX,
                              absTop = data.bound.top + distanceY,
                              absRight = absLeft + data.bound.width,
                              absBottom = absTop + data.bound.height;
                              
                              // 边缘检测
                              if (absLeft < 0) {
                              distanceX = distanceX - absLeft;
                              }
                              if (absTop < 0) {
                              distanceY = distanceY - absTop;
                              }
                              if (absRight > winWidth) {
                              distanceX = distanceX - (absRight - winWidth);
                              }
                              if (absBottom > winHeight) {
                              distanceY = distanceY - (absBottom - winHeight);
                              }
                              
                              // 元素位置跟随
                              var x = data.distanceX + distanceX, y = data.distanceY + distanceY;
                              fnTranslate(x, y);
                              
                              // 缓存移动位置
                              ele.distanceX = x;
                              ele.distanceY = y;
                              }, { // fix #3 #5
                              passive: false
                              });
    
    document.addEventListener('touchend', function () {
                              
                              if (data.touching === false) {
                              // fix iOS fixed bug
                              return;
                              }
                              data.touching = false;
                              
                              // 计算速度
                              data.timerend = +new Date();
                              
                              if (!data.nowX || !data.nowY) {
                              return;
                              }
                              
                              // 移动的水平和垂直距离
                              var distanceX = data.nowX - data.posX,
                              distanceY = data.nowY - data.posY;
                              
                              if (Math.abs(distanceX) < 5 && Math.abs(distanceY) < 5) {
                              return;
                              }
                              
                              // 距离和时间
                              var distance = Math.sqrt(distanceX * distanceX + distanceY * distanceY), time = data.timerend - data.timerstart;
                              
                              // 速度，每一个自然刷新此时移动的距离
                              var speed = distance / time * 16.666;
                              
                              // 经测试，2~60多px不等
                              // 设置衰减速率
                              // 数值越小，衰减越快
                              var rate = Math.min(10, speed);
                              
                              // 开始惯性缓动
                              data.inertiaing = true;
                              
                              // 反弹的参数
                              var reverseX = 1, reverseY = 1;
                              
                              // 速度计算法
                              var step = function () {
                              if (data.touching == true) {
                              data.inertiaing = false;
                              return;
                              }
                              speed = speed - speed / rate;
                              
                              // 根据运动角度，分配给x, y方向
                              var moveX = reverseX * speed * distanceX / distance, moveY = reverseY * speed * distanceY / distance;
                              
                              // 此时元素的各个数值
                              var bound = ele.getBoundingClientRect();
                              
                              if (moveX < 0 && bound.left + moveX < 0) {
                              moveX = 0 - bound.left;
                              // 碰触边缘方向反转
                              reverseX = reverseX * -1;
                              // ele.style.transform = 'translate3d(' + ['-25px', ele.distanceY + moveY + 'px', 0].join(',') + ')';
                              } else if (moveX > 0 && bound.right + moveX > winWidth) {
                              moveX = winWidth - bound.right;
                              reverseX = reverseX * -1;
                              // ele.style.transform = 'translate3d(' + [clientWidth + '-50px', ele.distanceY + moveY + 'px', 0].join(',') + ')';
                              }
                              
                              else if (moveY < 0 && bound.top + moveY < 0) {
                              moveY = -1 * bound.top;
                              reverseY = -1 * reverseY;
                              // ele.style.transform = 'translate3d(' + [ele.distanceX + moveX + 'px', '-50px', 0].join(',') + ')';
                              } else if (moveY > 0 && bound.bottom + moveY > winHeight) {
                              moveY = winHeight - bound.bottom;
                              reverseY = -1 * reverseY;
                              // ele.style.transform = 'translate3d(' + [ele.distanceX + moveX + 'px', clientHidth + '-60px', 0].join(',') + ')';
                              }
                              
                              var x = ele.distanceX + moveX, y = ele.distanceY + moveY;
                              // 位置变化
                              fnTranslate(x, y);
                              
                              ele.distanceX = x;
                              ele.distanceY = y;
                              
                              };
                              
                              
                              var edge = function () {
                              // 时间
                              var start = 0, during = 25;
                              // 初始值和变化量
                              var init = ele.distanceX, y = ele.distanceY, change = 0;
                              // 判断元素现在在哪个半区
                              var bound = ele.getBoundingClientRect();
                              if (bound.left + bound.width / 2 < winWidth / 2) {
                              change = -1 * bound.left;
                              } else {
                              change = winWidth - bound.right;
                              }
                              
                              var run = function () {
                              // 如果用户触摸元素，停止继续动画
                              if (data.touching == true) {
                              data.inertiaing = false;
                              return;
                              }
                              
                              start++;
                              var x = easeOutBounce(start, init, change, during);
                              fnTranslate(x, y);
                              
                              if (start < during) {
                              requestAnimationFrame(run);
                              } else {
                              ele.distanceX = x;
                              ele.distanceY = y;
                              
                              data.inertiaing = false;
                              if (win.localStorage) {
                              localStorage['Inertia_' + ele.id] = [x, y].join();
                              }
                              }
                              };
                              run();
                              };
                              
                              step();
                              });
};

new Inertia(document.getElementById('wrapper'));
