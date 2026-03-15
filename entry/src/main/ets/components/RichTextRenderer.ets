// entry/src/main/ets/components/RichTextRenderer.ets
/**
 * 🌾 农事富文本渲染组件
 * 基于 CjAgriMark 解析引擎规范，在 ArkTS 端实现渲染
 */

export interface RenderNode {
  type: number; // 0=plain 1=highlight 2=disease 3=product
  text: string;
  price: number;
}

export class AgriParserArkTS {
  /**
   * 解析农事专属语法
   * 支持：**高亮文本** [病害:名称] [农资:名称,价格]
   */
  static parse(input: string): RenderNode[] {
    const nodes: RenderNode[] = [];
    let remaining = input;

    while (remaining.length > 0) {
      // 1. 匹配高亮语法 **xxx**
      const highlightMatch = remaining.match(/^\*\*(.+?)\*\*/);
      if (highlightMatch && highlightMatch.length > 1) {
        nodes.push({ type: 1, text: highlightMatch[1], price: 0 });
        remaining = remaining.substring(highlightMatch[0].length);
        continue;
      }

      // 2. 匹配专属标签语法 [类型:名称,参数]
      const tagMatch = remaining.match(/^\[([^\]:]+):([^\]]+)\]/);
      if (tagMatch && tagMatch.length > 2) {
        const tagType = tagMatch[1];
        const tagData = tagMatch[2];

        if (tagType === '病害') {
          nodes.push({ type: 2, text: tagData, price: 0 });
        } else if (tagType === '农资') {
          const dataParts = tagData.split(',');
          if (dataParts.length >= 2) {
            const name = dataParts[0];
            const price = parseFloat(dataParts[1]) || 0;
            nodes.push({ type: 3, text: name, price: price });
          } else {
            nodes.push({ type: 3, text: tagData, price: 0 });
          }
        } else {
          nodes.push({ type: 0, text: tagMatch[0], price: 0 });
        }
        remaining = remaining.substring(tagMatch[0].length);
        continue;
      }

      // 3. 收集普通文本
      let plainText = '';
      const nextHighlight = remaining.indexOf('**');
      const nextTag = remaining.indexOf('[');

      let nextSpecial = -1;
      if (nextHighlight >= 0 && nextTag >= 0) {
        nextSpecial = Math.min(nextHighlight, nextTag);
      } else if (nextHighlight >= 0) {
        nextSpecial = nextHighlight;
      } else if (nextTag >= 0) {
        nextSpecial = nextTag;
      }

      if (nextSpecial === 0) {
        // 防止死循环
        nodes.push({ type: 0, text: remaining.charAt(0), price: 0 });
        remaining = remaining.substring(1);
      } else if (nextSpecial > 0) {
        plainText = remaining.substring(0, nextSpecial);
        nodes.push({ type: 0, text: plainText, price: 0 });
        remaining = remaining.substring(nextSpecial);
      } else {
        nodes.push({ type: 0, text: remaining, price: 0 });
        break;
      }
    }

    return nodes;
  }
}

@Component
export struct RichTextRenderer {
  @Prop content: string = '';
  @State renderNodes: RenderNode[] = [];

  aboutToAppear(): void {
    this.renderNodes = AgriParserArkTS.parse(this.content);
  }

  build() {
    Text() {
      ForEach(this.renderNodes, (node: RenderNode, index: number) => {
        if (node.type === 0) {
          Span(node.text)
            .fontSize(16)
            .fontColor('#333333')
        } else if (node.type === 1) {
          Span(node.text)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#E53935')
        } else if (node.type === 2) {
          Span('【🦠 ' + node.text + '】')
            .fontSize(15)
            .fontWeight(FontWeight.Bold)
            .fontColor('#D32F2F')
            .backgroundColor('#FFCDD2')
            .borderRadius(4)
        } else if (node.type === 3) {
          Span('【🛍️ ' + node.text + ' ¥' + node.price.toFixed(1) + '】')
            .fontSize(15)
            .fontWeight(FontWeight.Bold)
            .fontColor('#E65100')
            .backgroundColor('#FFE0B2')
            .borderRadius(4)
        }
      }, (node: RenderNode, index: number) => index.toString())
    }
    .width('100%')
  }
}
