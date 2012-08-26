/**
 * Created with IntelliJ IDEA.
 * User: fredericn
 * Date: 24/08/12
 * Time: 17:28
 * To change this template use File | Settings | File Templates.
 */
package ice.tools.display.prerenderer {

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Graphics;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import flash.system.ApplicationDomain;
import flash.utils.getQualifiedClassName;

import ice.wordox.gfx.JellyBirthAnimation;
import ice.wordox.gfx.JellyBreathingAnimation;
import ice.wordox.gfx.JellyDropAnimation;
import ice.wordox.gfx.JellyMovingAnimation;
import ice.wordox.gfx.JellyOutAnimation;
import ice.wordox.gfx.JellyOverAnimation;
import ice.wordox.gfx.JellyStealingAnimation;
import ice.wordox.gfx.JellyWinAnimation;

public class JellyAnimationCatalogue extends EventDispatcher{

    public function JellyAnimationCatalogue(eventdispatcher:IEventDispatcher) {
        _worker = new PrerenderedMovieClipWorker(eventdispatcher, 10);
    }

    public function initializeAllMovieclip():void {
        while (_jelliesClass.length > 0) {
            initializeMovieclip(_jelliesClass.pop());
        }
    }

    public function getJellyAnimation (animationClass : Class, playerSeat : int,  letterCode : int) : IPrerenderedMovieClip {
        var containerMovieClip : CompositePrerenderedClip = new CompositePrerenderedClip();

        var woxAnimationName:String = getQualifiedClassName(animationClass)+ "_"  + playerSeat; //  + "_ice.wordox.gfx::LetterCode15";//
        var letterAnimationName:String = getQualifiedClassName(animationClass)+ "_LETTER" + letterCode; //  + "_ice.wordox.gfx::LetterCode15";//

        containerMovieClip.addPrerenderedChild(_worker.getAnimation (woxAnimationName).clone());
        containerMovieClip.addPrerenderedChild(_worker.getAnimation(letterAnimationName).clone());
        containerMovieClip.play();
        return containerMovieClip;
    }

    public function get cataloguetotalSize () : int {
        return _worker.totalAnimations;
    }

    public function get catalogueCurrentSize () : int {
        return _worker.currentSize;
    }

    private function initializeMovieclip(animationClass:Class):void {
        _worker.addEventListener(PrerenderedMovieClipEvent.PRERENDER_END, onPrerenderEnd);
        var animationBounds:IAnimationBound;

        // Name of generate animation: [qualifiedClassName of animation]_[letter_index]
        for (var iPlayer:uint = 0; iPlayer < _playersColor.length; iPlayer++) {

            // Path for wox animation, by player:
            var _overlaySprite:Sprite = new Sprite();
            var jellyAnimation:MovieClip = new animationClass();
            try {
                jellyAnimation ["overlayClip"].addChild(_overlaySprite);
            } catch (error:Error) {
                trace("Error while adding overlay")
                return;
            }

            try {
                for (var i:uint = 0; i < jellyAnimation.letterContainer.numChildren; i++) {
                    var clip:DisplayObject = DisplayObjectContainer(jellyAnimation.letterContainer).getChildAt(i);
                    clip.visible = false;
                    clip.alpha = 0;
                }
            } catch (error:Error) {
//            Logger.warning(this, "Error while setting the letter on the animation", Version.getInstance());
            }

            animationBounds = MovieClipConversionUtils.getMaxSize(jellyAnimation);
            updateOverlayColor(_playersColor[iPlayer], _overlaySprite);
            _worker.addAnimation(getQualifiedClassName(jellyAnimation) + "_" + iPlayer, jellyAnimation, animationBounds);

        }

        for (var iLetterIndex : uint = 0; iLetterIndex < _LETTERS_CODES.length; iLetterIndex++) {
            // Path for letter animation:
            var jellyAnimation:MovieClip = new animationClass();
            jellyAnimation.graphics.clear();
            for (var iAnimationChildIndex : int = 0; iAnimationChildIndex < jellyAnimation.numChildren; iAnimationChildIndex++) {
                var child:DisplayObject = jellyAnimation.getChildAt(iAnimationChildIndex);
                child.visible = (child == jellyAnimation.letterContainer);
            }

            var letterClass:Class = ApplicationDomain.currentDomain.getDefinition(_letterClassPrefix + _LETTERS_CODES[iLetterIndex]) as Class;
            var letterClip:Sprite = new letterClass();
            var letterContainer:DisplayObjectContainer = DisplayObjectContainer(jellyAnimation.letterContainer);
            while(letterContainer.numChildren > 0) {
                letterContainer.removeChildAt(0);
            }
            letterContainer.addChild(letterClip);

            animationBounds = MovieClipConversionUtils.getMaxSize(jellyAnimation.letterContainer, jellyAnimation);
            var letterAnimationName:String = getQualifiedClassName(jellyAnimation) + "_LETTER" + _LETTERS_CODES[iLetterIndex];
            _worker.addAnimation(letterAnimationName, jellyAnimation, animationBounds);
        }
        _overlaySprite = null;
    }

    private function onPrerenderEnd(event:PrerenderedMovieClipEvent):void {
        _worker.removeEventListener(PrerenderedMovieClipEvent.PRERENDER_END, onPrerenderEnd);
        dispatchEvent(event);
    }

    private static function updateOverlayColor(playerColor:int, overlayClip:Sprite):void {
        var graphics:Graphics = overlayClip.graphics;
        graphics.clear();
        graphics.beginFill(playerColor);
        graphics.moveTo(-1, -15);
        graphics.lineTo(-1, _LETTER_SIZE + 30);
        graphics.lineTo(_LETTER_SIZE + 2, _LETTER_SIZE + 30);
        graphics.lineTo(_LETTER_SIZE + 2, -15);
        graphics.endFill();
    }

    private const _playersColor:Array = [0x1DA7E0, 0x76CF26, 0xEA4CA1, 0xFEA421];
    private const _jelliesClass:Array =
//            [JellyStealingAnimation];
            [JellyBirthAnimation, JellyDropAnimation, JellyMovingAnimation, JellyOutAnimation, JellyOverAnimation
        , JellyBreathingAnimation, JellyStealingAnimation, JellyWinAnimation];
    private static const _LETTER_SIZE:int = 45;

    private static const _letterClassPrefix:String = "ice.wordox.gfx.LetterCode";
    private static const _LETTERS_CODES:Array = [
        1, 2, 3, 4, 5, 6, 7, 8, 9, 10
        , 11, 12, 13, 14, 15, 16, 17, 18, 19, 20
        , 21, 22, 23, 24, 25, 26, 27, 28, 29, 30
        , 1000, 1001, 1002, 1003, 1004, 1005, 1006, 1007, 1008, 1009
    ]

    private static var _worker:PrerenderedMovieClipWorker;
}
}
