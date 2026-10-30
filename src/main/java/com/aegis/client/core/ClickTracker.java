package com.aegis.client.core;

import org.lwjgl.glfw.GLFW;

import java.util.ArrayDeque;
import java.util.Deque;

/** Counts physical mouse-down transitions while Minecraft has no screen open. */
public final class ClickTracker {
    private static final long WINDOW_NANOS = 1_000_000_000L;
    private static final Deque<Long> LEFT = new ArrayDeque<>();
    private static final Deque<Long> RIGHT = new ArrayDeque<>();
    private static boolean leftWasDown;
    private static boolean rightWasDown;

    private ClickTracker() {}

    public static synchronized void poll(long windowHandle, boolean gameplayInputAllowed) {
        long now = System.nanoTime();
        if (!gameplayInputAllowed || windowHandle == 0L) {
            leftWasDown = false;
            rightWasDown = false;
            prune(now);
            return;
        }

        boolean leftDown = GLFW.glfwGetMouseButton(windowHandle, GLFW.GLFW_MOUSE_BUTTON_LEFT) == GLFW.GLFW_PRESS;
        boolean rightDown = GLFW.glfwGetMouseButton(windowHandle, GLFW.GLFW_MOUSE_BUTTON_RIGHT) == GLFW.GLFW_PRESS;

        if (leftDown && !leftWasDown) LEFT.addLast(now);
        if (rightDown && !rightWasDown) RIGHT.addLast(now);

        leftWasDown = leftDown;
        rightWasDown = rightDown;
        prune(now);
    }

    public static synchronized int leftCps() {
        prune(System.nanoTime());
        return LEFT.size();
    }

    public static synchronized int rightCps() {
        prune(System.nanoTime());
        return RIGHT.size();
    }

    private static void prune(long now) {
        while (!LEFT.isEmpty() && now - LEFT.peekFirst() > WINDOW_NANOS) LEFT.removeFirst();
        while (!RIGHT.isEmpty() && now - RIGHT.peekFirst() > WINDOW_NANOS) RIGHT.removeFirst();
    }
}
