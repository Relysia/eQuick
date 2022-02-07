import Nav from './Nav';
import styles from '../styles/Layout.module.sass';

function Layout({ children }) {
  return (
    <>
      <Nav />
      <main className={styles.main} style={{ backgroundImage: "url('background.jpg')" }}>
        {children}
      </main>
    </>
  );
}

export default Layout;
