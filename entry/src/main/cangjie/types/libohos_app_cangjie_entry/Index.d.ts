export declare interface IJSCallback {
    invoke: () => void
}

export declare function testCJ(arg1: string): string
export declare function registerJSFunc(name: string, fn: IJSCallback): void
export declare function unregisterJSFunc(name: string): void
export declare function getQA_Question(): string
export declare function getQA_Answer(): string
export declare function syncQA_Action(arg1: number, arg2: number): void

// 🌟 只留这个你测试好用的收藏专线！别的全删！
export declare function registerFavCallback(callback: () => void): void;
export declare function registerFavCallback(): void

export declare function registerCommentCallback(): void
