export declare interface IJSCallback {
    invoke: () => void
}

export declare interface IJSCallback {
    invoke: () => void
}

export declare interface IJSCallback {
    invoke: () => void
}

export declare interface CustomLib {
    registerJSFunc(name: string, fn: () => void): void
    unregisterJSFunc(name: string): void
    registerJSFunc(name: string, fn: () => void): void
    unregisterJSFunc(name: string): void
    registerJSFunc(name: string, fn: () => void): void
    unregisterJSFunc(name: string): void
    registerJSFunc(name: string, fn: IJSCallback): void
    getQA_Question(): string
    getQA_Answer(): string
    syncQA_Action(likes: number, dislikes: number): void
    registerJSFunc(name: string, fn: IJSCallback): void
    unregisterJSFunc(name: string): void
    registerJSFunc(name: string, fn: IJSCallback): void
    unregisterJSFunc(name: string): void
    registerFavCallback(): void
    testCJ(arg1: string): string
    getQA_Question(): string
    getQA_Answer(): string
    syncQA_Action(arg1: number, arg2: number): void
    registerCommentCallback(): void
}