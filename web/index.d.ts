export declare class WasmBridge {
    private client;
    private db;
    _init(): Promise<void>;
    init(): Promise<boolean>;
    joinFederation(configUrl: string): Promise<void>;
    leaveFederation(): Promise<void>;
    balance(): Promise<number>;
    decodeInvoice(invoice: string): string;
    invoice(amount: number, description: string): Promise<string>;
    pay(bolt11: string): Promise<string>;
}
export declare const wasmBridge: WasmBridge;
