import Document, { Html, Head, Main, NextScript } from 'next/document';

class MyDocument extends Document {
  render() {
    return (
      <Html lang='hu'>
        <Head />
        <body>
          <Main />
          <NextScript />
        </body>
        <script src='https://cdnjs.cloudflare.com/ajax/libs/jquery/3.1.0/jquery.min.js'></script>
      </Html>
    );
  }
}

export default MyDocument;
